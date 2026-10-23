//
// Copyright 2024 New Vector Ltd.
// Copyright 2020 Vector Creations Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import UIKit
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties

    // MARK: Private

    private var appCoordinator: AppCoordinatorType!
    private var rootRouter: RootRouterType!

    private var legacyAppDelegate: LegacyAppDelegate {
        return AppDelegate.theDelegate()
    }
    
    // MARK: Public
    
    /// Call the Riot legacy AppDelegate
    @objc class func theDelegate() -> LegacyAppDelegate {
        guard let legacyAppDelegate = LegacyAppDelegate.the() else {
            fatalError("[AppDelegate] theDelegate property should not be nil")
        }
        return legacyAppDelegate
    }
    
    // UIApplicationDelegate properties
    
    /// Main application window
    var window: UIWindow?
    
    // MARK: - UIApplicationDelegate
    
    // MARK: Life cycle
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return self.legacyAppDelegate.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup window
        let window = SecureWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // Create AppCoordinator
        self.rootRouter = RootRouter(window: window)
        
        let appCoordinator = AppCoordinator(router: self.rootRouter, window: window)
        appCoordinator.start()
        self.legacyAppDelegate.delegate = appCoordinator
        
        self.appCoordinator = appCoordinator
        
        // Call legacy AppDelegate
        self.legacyAppDelegate.window = window
        self.legacyAppDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Prevent screenshots and screen recordings of the app content
        DispatchQueue.main.async {
            window.enableScreenshotProtection()
        }

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidBecomeActive(application)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {        
        self.legacyAppDelegate.applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillEnterForeground(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.legacyAppDelegate.applicationWillTerminate(application)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        self.legacyAppDelegate.applicationDidReceiveMemoryWarning(application)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.appCoordinator.open(url: url, options: options)
    }
    
    // MARK: User Activity Continuation
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return self.legacyAppDelegate.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // MARK: Push Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.legacyAppDelegate.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.legacyAppDelegate.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.legacyAppDelegate.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}

// MARK: - Screenshot protection

/// A window that hosts its own layer inside the canvas of a secure text field, so that
/// iOS blanks the app content in screenshots, screen recordings and AirPlay mirroring.
///
/// This depends on `UITextField`'s internal view structure, so it fails safe: when the
/// secure canvas cannot be found the window is left untouched and the app runs as usual,
/// without the protection, rather than with a broken layout.
final class SecureWindow: UIWindow {

    private let secureField = UITextField()
    private weak var secureCanvasLayer: CALayer?

    /// Move the window's layer inside the secure canvas.
    /// Call this once the window is on screen, i.e. after `makeKeyAndVisible()`.
    @discardableResult
    func enableScreenshotProtection() -> Bool {
        guard secureCanvasLayer == nil, let superlayer = layer.superlayer else { return false }

        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        secureField.isAccessibilityElement = false
        secureField.frame = CGRect(origin: .zero, size: bounds.size)
        addSubview(secureField)
        secureField.layoutIfNeeded()

        // Pick the canvas by its owning class rather than by index: the order of the
        // text field sublayers is not stable across iOS versions. On iOS 17 and later
        // the first sublayer is the touch passthrough view, not the secure canvas.
        guard let canvasLayer = secureField.layer.sublayers?.first(where: { sublayer in
            guard let delegate = sublayer.delegate else { return false }
            return String(describing: type(of: delegate)).contains("TextLayoutCanvas")
        }) else {
            MXLog.warning("[SecureWindow] Secure canvas not found, screenshot protection is disabled")
            secureField.removeFromSuperview()
            return false
        }

        superlayer.addSublayer(secureField.layer)
        canvasLayer.addSublayer(layer)
        secureCanvasLayer = canvasLayer
        updateSecureCanvasGeometry()

        return true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Once the window layer has been moved into it, the secure field is no longer
        // laid out against the window, so its geometry has to be kept in sync by hand
        // on rotation and on any other bounds change.
        updateSecureCanvasGeometry()
    }

    private func updateSecureCanvasGeometry() {
        guard let canvasLayer = secureCanvasLayer else { return }

        let frame = CGRect(origin: .zero, size: bounds.size)
        guard canvasLayer.frame != frame || secureField.layer.frame != frame else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        secureField.frame = frame
        secureField.layer.frame = frame
        secureField.layoutIfNeeded()
        canvasLayer.frame = frame
        canvasLayer.masksToBounds = false
        layer.frame = frame
        CATransaction.commit()
    }
}
