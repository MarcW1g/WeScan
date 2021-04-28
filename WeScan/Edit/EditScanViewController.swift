//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

/// The `EditScanViewController` offers an interface for the user to edit the detected quadrilateral.
final class EditScanViewController: UIViewController {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()

    private lazy var nextButton: CircularImageButton = {
        let button = CircularImageButton(
            image: UIImage(
                named: "checkmark",
                in: Bundle(for: ScannerViewController.self),
                compatibleWith: nil
            )?.withRenderingMode(.alwaysTemplate))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pushReviewController), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let title = NSLocalizedString(
            "wescan.scanning.cancel",
            tableName: nil,
            bundle: Bundle(for: EditScanViewController.self),
            value: "Cancel",
            comment: "A generic cancel button"
        )
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()

    private lazy var onlyContentMessageLabelView: UIView = {
        let messageLabelView = UIView()
        messageLabelView.backgroundColor = UIColor.white
        messageLabelView.layer.cornerRadius = 5
        messageLabelView.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = "Only select the area with the products and total price"
        messageLabel.textColor = .darkBlue
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabelView.addSubview(messageLabel)

        let closeIcon = UIImage(
            named: "close",
            in: Bundle(for: ScannerViewController.self),
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
        let closeIconImageView = UIImageView(image: closeIcon)
        closeIconImageView.tintColor = .systemGray
        closeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabelView.addSubview(closeIconImageView)

        let closeButton = UIButton()
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabelView.addSubview(closeButton)

        let messageLabelConstraints = [
            messageLabel.leadingAnchor.constraint(equalTo: messageLabelView.leadingAnchor, constant: 20),
            messageLabel.topAnchor.constraint(equalTo: messageLabelView.topAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: messageLabelView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: messageLabelView.bottomAnchor, constant: -8)
        ]

        let closeIconImageViewConstraints = [
            closeIconImageView.topAnchor.constraint(equalTo: messageLabelView.topAnchor, constant: 4),
            closeIconImageView.trailingAnchor.constraint(equalTo: messageLabelView.trailingAnchor, constant: -4),
            closeIconImageView.widthAnchor.constraint(equalToConstant: 20),
            closeIconImageView.heightAnchor.constraint(equalToConstant: 20)
        ]

        let closeButtonConstraints = [
            closeButton.topAnchor.constraint(equalTo: messageLabelView.topAnchor, constant: 0),
            closeButton.trailingAnchor.constraint(equalTo: messageLabelView.trailingAnchor, constant: 0),
            closeButton.bottomAnchor.constraint(equalTo: messageLabelView.centerYAnchor, constant: 0),
            closeButton.widthAnchor.constraint(equalToConstant: 60)
        ]

        NSLayoutConstraint.activate(messageLabelConstraints + closeIconImageViewConstraints + closeButtonConstraints)

        return messageLabelView
    }()

    /// The image the quadrilateral was detected on.
    private let image: UIImage

    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral

    private var zoomGestureController: ZoomGestureController!

    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()

    // MARK: - Life Cycle

    init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = quad ?? EditScanViewController.defaultQuad(forImage: image)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        title = NSLocalizedString(
            "wescan.edit.title",
            tableName: nil,
            bundle: Bundle(for: EditScanViewController.self),
            value: "Edit Scan",
            comment: "The title of the EditScanViewController"
        )
        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }

        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)

        let touchDown = UILongPressGestureRecognizer(
            target: zoomGestureController,
            action: #selector(zoomGestureController.handle(pan:))
        )
        touchDown.delegate = self
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Work around for an iOS 11.2 bug where UIBarButtonItems
        // don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }

    // MARK: - Setups

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(onlyContentMessageLabelView)
        view.addSubview(nextButton)
    }

    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)

        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]

        var nextButtonConstraints = [
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 65.0),
            nextButton.heightAnchor.constraint(equalToConstant: 65.0)
        ]

        let onlyContentMessageLabelViewConstraints: [NSLayoutConstraint]
        if #available(iOS 11.0, *) {
            onlyContentMessageLabelViewConstraints = [
                onlyContentMessageLabelView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 8
                ),
                onlyContentMessageLabelView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 8
                ),
                onlyContentMessageLabelView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -8
                )
            ]

            let nextButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: nextButton.bottomAnchor,
                constant: 8.0
            )
            nextButtonConstraints.append(nextButtonBottomConstraint)
        } else {
            onlyContentMessageLabelViewConstraints = [
                onlyContentMessageLabelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
                onlyContentMessageLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                onlyContentMessageLabelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
            ]

            let nextButtonBottomConstraint = view.bottomAnchor.constraint(
                equalTo: nextButton.bottomAnchor,
                constant: 8.0
            )
            nextButtonConstraints.append(nextButtonBottomConstraint)
        }

        NSLayoutConstraint.activate(
            quadViewConstraints +
                imageViewConstraints +
                onlyContentMessageLabelViewConstraints +
                nextButtonConstraints
        )
    }

    // MARK: - Actions
    @objc func cancelButtonTapped() {
        if let imageScannerController = navigationController as? ImageScannerController {
            imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
        }
    }

    @objc func pushReviewController() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    let error = ImageScannerControllerError.ciImageCreation
                    imageScannerController.imageScannerDelegate?.imageScannerController(
                        imageScannerController, didFailWithError: error
                    )
                }
                return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }

        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: croppedImage),
            enhancedScan: enhancedScan
        )

        let reviewViewController = ReviewViewController(results: results)
        navigationController?.pushViewController(reviewViewController, animated: true)
    }

    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(
            origin: quadView.frame.origin,
            size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant)
        )

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }

    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time,
    /// we adjust the constraints to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }

    /// Generates a `Quadrilateral` object that's centered and 90% of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.05)
        let topRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.05)
        let bottomRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.95)
        let bottomLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.95)

        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        return quad
    }

    // MARK: - Actions
    @objc private func closePopup() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.onlyContentMessageLabelView.alpha = 0
        } completion: { [weak self] (_) in
            self?.onlyContentMessageLabelView.isHidden = true
        }

    }
}

extension EditScanViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if touch.view?.isDescendant(of: nextButton) ?? false ||
            touch.view?.isDescendant(of: onlyContentMessageLabelView) ?? false {
            return false
        }

        return true
    }
}
