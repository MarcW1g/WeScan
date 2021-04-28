//
//  FinishedButton.swift
//  WeScan
//
//  Created by Marc Wiggerman on 24/04/2021.
//  Copyright © 2021 WeTransfer. All rights reserved.
//

import UIKit

class CircularImageButton: UIControl {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let innerCircleLayer = CAShapeLayer()

    private let innerRingRatio: CGFloat = 1

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateInnerCircleLayer(forHighlightedState: isHighlighted)
            }
        }
    }

    // MARK: - Life Cycle

    convenience init(image: UIImage?) {
        self.init(frame: .zero)
        imageView.image = image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(innerCircleLayer)
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        impactFeedbackGenerator.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        innerCircleLayer.frame = rect
        innerCircleLayer.path = pathForInnerCircle(inRect: rect).cgPath
        innerCircleLayer.fillColor = UIColor.cbsPurple.cgColor
        innerCircleLayer.rasterizationScale = UIScreen.main.scale
        innerCircleLayer.shouldRasterize = true

        addImage()
    }

    // MARK: - Animation

    private func animateInnerCircleLayer(forHighlightedState isHighlighted: Bool) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        var values = [CATransform3DMakeScale(1.0, 1.0, 1.0), CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(0.93, 0.93, 0.93), CATransform3DMakeScale(0.9, 0.9, 0.9)]
        if isHighlighted == false {
            values = [CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(1.0, 1.0, 1.0)]
        }
        animation.values = values
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = isHighlighted ? 0.35 : 0.10

        innerCircleLayer.add(animation, forKey: "transform")
        imageView.layer.add(animation, forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }

    // MARK: - Paths
    private func pathForInnerCircle(inRect rect: CGRect) -> UIBezierPath {
        let rect = rect.scaleAndCenter(withRatio: innerRingRatio)
        let path = UIBezierPath(ovalIn: rect)

        return path
    }

    // MARK: - Image
    private func addImage() {
        addSubview(imageView)

        let leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20)
        let trailingConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20)
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20)
        let bottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -20)

        addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}
