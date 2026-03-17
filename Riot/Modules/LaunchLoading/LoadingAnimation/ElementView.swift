// Made With Flow.
//
// DO NOT MODIFY, your changes will be lost when this file is regenerated.
//

import UIKit
import FlowCommoniOS

@IBDesignable
public class ElementView: UIView {
    public struct Defaults {
        public static let size = CGSize(width: 130.16, height: 127.75)
        public static let backgroundColor = UIColor.clear
    }

    private var imageView: UIImageView!

    public override var intrinsicContentSize: CGSize {
        return Defaults.size
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        clipsToBounds = false
        createViews()
        addSubviews()
    }

    public func scale(to size: CGSize) {
        let x = size.width / Defaults.size.width
        let y = size.height / Defaults.size.height
        transform = CGAffineTransform(scaleX: x, y: y)
    }

    private func createViews() {
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let image = UIImage(named: "launch_screen_logo") {
            print("✅ Image loaded successfully")
            imageView.image = image
        } else {
            print("❌ Image NOT found - check the name in Images.xcassets")
        }
    }

    private func addSubviews() {
        addSubview(imageView)
    }
}
