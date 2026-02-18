//
//  VaccineAnnotationView.swift
//  WC Vax
//
//  Custom annotation view for vaccine locations
//

import MapKit
import UIKit

class VaccineAnnotationView: MKAnnotationView {
    
    private let pinSize: CGFloat = 50
    private let pulseSize: CGFloat = 70
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pulseLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.opacity = 0
        return layer
    }()
    
    private lazy var pinBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = pinSize / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: pulseSize, height: pulseSize)
        centerOffset = CGPoint(x: 0, y: -pinSize / 2)
        
        addSubview(containerView)
        containerView.addSubview(pinBackgroundView)
        pinBackgroundView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: pinSize),
            containerView.heightAnchor.constraint(equalToConstant: pinSize),
            
            pinBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pinBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pinBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pinBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: pinBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: pinBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        layer.insertSublayer(pulseLayer, at: 0)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let vaccineLocation = annotation as? VaccineLocation else { return }
        
        // Update colors
        pinBackgroundView.backgroundColor = vaccineLocation.primaryColor
        
        // Update icon
        if let vaccine = vaccineLocation.vaccines.first {
            iconImageView.image = UIImage(systemName: vaccine.icon)
        }
        
        displayPriority = .required
    }
    
    func animateSelection() {
        // Bounce animation
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
        
        // Pulse animation
        animatePulse()
    }
    
    private func animatePulse() {
        guard let vaccineLocation = annotation as? VaccineLocation else { return }
        
        let pulsePath = UIBezierPath(ovalIn: CGRect(x: bounds.midX - pulseSize/2,
                                                     y: bounds.midY - pulseSize/2,
                                                     width: pulseSize,
                                                     height: pulseSize))
        
        pulseLayer.path = pulsePath.cgPath
        pulseLayer.fillColor = vaccineLocation.primaryColor.cgColor
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 0
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.5
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1
        
        pulseLayer.add(animationGroup, forKey: "pulse")
    }
}
