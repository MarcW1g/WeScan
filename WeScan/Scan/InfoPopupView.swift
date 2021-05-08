//
//  InfoPopupView.swift
//  WeScan
//
//  Created by Marc Wiggerman on 19/04/2021.
//  Copyright © 2021 WeTransfer. All rights reserved.
//

import UIKit

public protocol InfoPopupViewProtocol {
    func hideInfoPopup()
}

class InfoPopupView: UIView {
    
    public var delegate: InfoPopupViewProtocol?
    
    private lazy var tipsOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let closeImage = UIImage(named: "close", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(closeImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .darkBlue
        button.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return button
    }()
    
    private lazy var tipsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tips"
        label.textColor = .darkBlue
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var tipsTitleIcon: UIImageView = {
        let lightbulbImage = UIImage(named: "lightbulb", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: lightbulbImage)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkBlue
        return imageView
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var understoodButton: UIButton = {
        let button = UIButton()
        button.setTitle("Begrepen", for: .normal)
        button.backgroundColor = .darkBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        button.layer.cornerRadius = 5
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.3
        
        button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
        button.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tipsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var tipsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Setups
    public func setupWithTips(tips: [String]) {
        setupViews(withTips: tips)
    }
    
    private func setupViews(withTips tips: [String]) {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        addSubview(tipsOverlay)
        
        tipsOverlay.addSubview(closeButton)
        
        tipsOverlay.addSubview(titleStackView)
        titleStackView.addArrangedSubview(tipsTitleIcon)
        titleStackView.addArrangedSubview(tipsTitleLabel)
        
        tipsOverlay.addSubview(understoodButton)
        
        tipsOverlay.addSubview(tipsScrollView)
        tipsScrollView.addSubview(tipsStackView)
        
        setupConstraints()
        
        addTips(tips)
    }
    
    private func setupConstraints() {
        var tipsOverlayConstraints = [NSLayoutConstraint]()
        var closeButtonConstraints = [NSLayoutConstraint]()
        var titleStackViewConstraints = [NSLayoutConstraint]()
        var understoodButtonConstraints = [NSLayoutConstraint]()
        var tipsScrollViewConstraints = [NSLayoutConstraint]()
        var tipsStackViewConstraints = [NSLayoutConstraint]()
        
        tipsOverlayConstraints = [
            tipsOverlay.topAnchor.constraint(equalTo: topAnchor, constant: 64),
            tipsOverlay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -128),
            tipsOverlay.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            tipsOverlay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ]
        
        closeButtonConstraints = [
            closeButton.topAnchor.constraint(equalTo: tipsOverlay.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: tipsOverlay.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        titleStackViewConstraints = [
            titleStackView.topAnchor.constraint(equalTo: tipsOverlay.topAnchor, constant: 32),
            titleStackView.centerXAnchor.constraint(equalTo: tipsOverlay.centerXAnchor),
            titleStackView.widthAnchor.constraint(equalToConstant: 75)
        ]
        
        understoodButtonConstraints = [
            understoodButton.bottomAnchor.constraint(equalTo: tipsOverlay.bottomAnchor, constant: -32),
            understoodButton.centerXAnchor.constraint(equalTo: tipsOverlay.centerXAnchor),
            understoodButton.heightAnchor.constraint(equalToConstant: 45),
            understoodButton.widthAnchor.constraint(equalToConstant: 175)
        ]
        
        tipsScrollViewConstraints = [
            tipsScrollView.leadingAnchor.constraint(equalTo: tipsOverlay.leadingAnchor, constant: 24),
            tipsScrollView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 16),
            tipsScrollView.trailingAnchor.constraint(equalTo: tipsOverlay.trailingAnchor, constant: -24),
            tipsScrollView.bottomAnchor.constraint(equalTo: understoodButton.topAnchor, constant: -16),
        ]
        
        tipsStackViewConstraints = [
            tipsStackView.leadingAnchor.constraint(equalTo: tipsScrollView.leadingAnchor),
            tipsStackView.topAnchor.constraint(equalTo: tipsScrollView.topAnchor),
            tipsStackView.trailingAnchor.constraint(equalTo: tipsScrollView.trailingAnchor),
            tipsStackView.bottomAnchor.constraint(equalTo: tipsScrollView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(tipsOverlayConstraints + closeButtonConstraints + titleStackViewConstraints + understoodButtonConstraints + tipsScrollViewConstraints + tipsStackViewConstraints)
    }
    
    private func addTips(_ tips: [String]) {
        for (index, tip) in tips.enumerated() {
            let tipView = UIView()
            tipView.translatesAutoresizingMaskIntoConstraints = false
            
            let numberLabel = UILabel()
            numberLabel.text = "\(index + 1)."
            numberLabel.font = .systemFont(ofSize: 25, weight: .black)
            numberLabel.textColor = .darkBlue
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            tipView.addSubview(numberLabel)
            
            let tipLabel = UILabel()
            tipLabel.text = tip
            tipLabel.font = .systemFont(ofSize: 16, weight: .medium)
            tipLabel.textColor = .darkBlue
            tipLabel.numberOfLines = 0
            tipLabel.translatesAutoresizingMaskIntoConstraints = false
            tipView.addSubview(tipLabel)
            
            let leadingNumberConstraints = [
                numberLabel.leadingAnchor.constraint(equalTo: tipView.leadingAnchor),
                numberLabel.topAnchor.constraint(equalTo: tipView.topAnchor, constant: 2),
                numberLabel.widthAnchor.constraint(equalToConstant: 30)
            ]
            
            let tipLabelConstraints = [
                tipLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 8),
                tipLabel.topAnchor.constraint(equalTo: tipView.topAnchor),
                tipLabel.trailingAnchor.constraint(equalTo: tipView.trailingAnchor)
            ]
            
            let tipViewConstraints = [
                tipView.widthAnchor.constraint(equalTo: tipsScrollView.widthAnchor),
                tipView.heightAnchor.constraint(equalToConstant: 60)
            ]
            
            tipsStackView.addArrangedSubview(tipView)
            
            NSLayoutConstraint.activate(tipViewConstraints + leadingNumberConstraints + tipLabelConstraints)
        }
    }
    
    // MARK: - Actions
    @objc private func closePopup(_ sender: UIButton) {
        delegate?.hideInfoPopup()
    }
}
