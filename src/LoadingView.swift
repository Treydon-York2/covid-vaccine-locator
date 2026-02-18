//
//  LoadingView.swift
//  WC Vax
//
//  Beautiful loading screen
//

import UIKit

class LoadingView: UIView {
    
    // Logo icon with gradient background
    private lazy var logoContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemTeal
        container.layer.cornerRadius = 30
        container.layer.shadowColor = UIColor.systemTeal.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        container.layer.shadowRadius = 20
        container.layer.shadowOpacity = 0.4
        return container
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "cross.case.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WC Vax"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vaccine Finder"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemTeal
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Finding locations near you..."
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .systemTeal
        indicator.startAnimating()
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startAnimations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        startAnimations()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(logoContainer)
        logoContainer.addSubview(iconImageView)
        addSubview(appNameLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -120),
            logoContainer.widthAnchor.constraint(equalToConstant: 140),
            logoContainer.heightAnchor.constraint(equalToConstant: 140),
            
            iconImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            appNameLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 32),
            appNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            appNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func startAnimations() {
        // Start with everything invisible
        logoContainer.alpha = 0
        logoContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        appNameLabel.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        
        // Animate logo container
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: []) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = .identity
        }
        
        // Animate app name
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut) {
            self.appNameLabel.alpha = 1
        }
        
        // Animate title
        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
        }
        
        // Animate subtitle
        UIView.animate(withDuration: 0.6, delay: 0.7, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
        }
        
        // Pulse animation for logo
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        logoContainer.layer.add(pulseAnimation, forKey: "pulse")
        
        // Glow animation
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.duration = 2.0
        glowAnimation.fromValue = 0.4
        glowAnimation.toValue = 0.8
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        logoContainer.layer.add(glowAnimation, forKey: "glow")
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
