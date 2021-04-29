//
//  ReviewViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it has been cropped and deskwed according to the passed in quadrilateral.
final class ReviewViewController: UIViewController {

    private var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
    private var enhancedImageIsAvailable = false
    private var isCurrentlyDisplayingEnhancedImage = false

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = results.croppedScan.image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var enhanceButton: UIButton = {
        let image = UIImage(
            named: "enhance",
            in: Bundle(for: ScannerViewController.self),
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
        
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(toggleEnhancedImage), for: .touchUpInside)
        button.tintColor = .cbsPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var rotateButton: UIButton = {
        let image = UIImage(
            named: "rotate",
            in: Bundle(for: ScannerViewController.self),
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(rotateImage), for: .touchUpInside)
        button.tintColor = .cbsPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var doneButton: CircularImageButton = {
        let button = CircularImageButton(
            image: UIImage(
                named: "checkmark",
                in: Bundle(for: ScannerViewController.self),
                compatibleWith: nil
            )?.withRenderingMode(.alwaysTemplate))
        button.addTarget(self, action: #selector(finishScan), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let results: ImageScannerResults

    // MARK: - Life Cycle

    init(results: ImageScannerResults) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedScan != nil

        setupViews()
        setupConstraints()

        title = NSLocalizedString("wescan.review.title", tableName: nil, bundle: Bundle(for: ReviewViewController.self), value: "Review", comment: "The review title of the ReviewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: Setups

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(doneButton)
        view.addSubview(rotateButton)
        
        if enhancedImageIsAvailable {
            view.addSubview(enhanceButton)
        }
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        var imageViewConstraints: [NSLayoutConstraint] = []
        var doneButtonConstraints: [NSLayoutConstraint] = []
        var rotateButtonConstraints: [NSLayoutConstraint] = []
        
        doneButtonConstraints = [
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 65.0),
            doneButton.heightAnchor.constraint(equalToConstant: 65.0)
        ]
        
        rotateButtonConstraints = [
            rotateButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            rotateButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
            rotateButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor),
            rotateButton.heightAnchor.constraint(equalTo: doneButton.heightAnchor)
        ]
        
        if #available(iOS 11.0, *) {
            imageViewConstraints = [
                view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.topAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor),
                view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor)
            ]
            
            let doneButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: doneButton.bottomAnchor,
                constant: 8.0
            )
            doneButtonConstraints.append(doneButtonBottomConstraint)
        } else {
            imageViewConstraints = [
                view.topAnchor.constraint(equalTo: imageView.topAnchor),
                view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
            ]
            
            let doneButtonBottomConstraint = view.bottomAnchor.constraint(
                equalTo: doneButton.bottomAnchor,
                constant: 8.0
            )
            doneButtonConstraints.append(doneButtonBottomConstraint)
        }

        NSLayoutConstraint.activate(imageViewConstraints + doneButtonConstraints + rotateButtonConstraints)
        
        if enhancedImageIsAvailable {
            let enhanceButtonConstraints: [NSLayoutConstraint] = [
                enhanceButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
                enhanceButton.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 8),
                enhanceButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor),
                enhanceButton.heightAnchor.constraint(equalTo: doneButton.heightAnchor)
            ]
            NSLayoutConstraint.activate(enhanceButtonConstraints)
        }
    }

    // MARK: - Actions

    @objc private func reloadImage() {
        if enhancedImageIsAvailable, isCurrentlyDisplayingEnhancedImage {
            imageView.image = results.enhancedScan?.image.rotated(by: rotationAngle) ?? results.enhancedScan?.image
        } else {
            imageView.image = results.croppedScan.image.rotated(by: rotationAngle) ?? results.croppedScan.image
        }
    }

    @objc func toggleEnhancedImage() {
        guard enhancedImageIsAvailable else { return }

        isCurrentlyDisplayingEnhancedImage.toggle()
        reloadImage()

        if isCurrentlyDisplayingEnhancedImage {
            enhanceButton.tintColor = .yellow
        } else {
            enhanceButton.tintColor = .cbsPurple
        }
    }

    @objc func rotateImage() {
        rotationAngle.value += 90

        if rotationAngle.value == 360 {
            rotationAngle.value = 0
        }

        reloadImage()
    }

    @objc private func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }

        var newResults = results
        newResults.croppedScan.rotate(by: rotationAngle)
        newResults.enhancedScan?.rotate(by: rotationAngle)
        newResults.doesUserPreferEnhancedScan = isCurrentlyDisplayingEnhancedImage
        imageScannerController.imageScannerDelegate?.imageScannerController(
            imageScannerController,
            didFinishScanningWithResults: newResults
        )
    }

}
