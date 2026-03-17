// Made With Flow.
//
// DO NOT MODIFY, your changes will be lost when this file is regenerated.
//
// swiftlint:disable all

import UIKit
import FlowCommoniOS

public class Timeline_1: Timeline {
    public convenience init(view: ElementView, duration: TimeInterval, autoreverses: Bool = false, repeatCount: Float = 0) {
        let animationsByLayer = [CALayer: [CAKeyframeAnimation]]()
        self.init(view: view, animationsByLayer: animationsByLayer, sounds: [], duration: duration, autoreverses: autoreverses, repeatCount: repeatCount)
    }
}
