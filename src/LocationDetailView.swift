//
//  LocationDetailView.swift
//  WC Vax
//
//  Bottom sheet showing vaccine location details
//

import UIKit
import MapKit

class LocationDetailView: UIView {
    
    private let location: VaccineLocation
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var vaccinesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var directionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Directions", for: .normal)
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond.fill"), for: .normal)
        button.backgroundColor = .systemTeal
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(directionsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Call", for: .normal)
        button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [directionsButton, callButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(location: VaccineLocation) {
        self.location = location
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.1
        
        addSubview(handleView)
        addSubview(titleLabel)
        addSubview(addressLabel)
        addSubview(vaccinesStackView)
        addSubview(buttonsStackView)
        
        titleLabel.text = location.title
        addressLabel.text = location.address ?? "Address not available"
        
        // Add vaccine badges
        for vaccine in location.vaccines {
            let badge = createVaccineBadge(for: vaccine)
            vaccinesStackView.addArrangedSubview(badge)
        }
        
        // Hide call button if no phone number
        if location.phoneNumber == nil {
            callButton.isHidden = true
        }
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            vaccinesStackView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 20),
            vaccinesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vaccinesStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            buttonsStackView.topAnchor.constraint(equalTo: vaccinesStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 50),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func createVaccineBadge(for vaccine: VaccineType) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = vaccine.color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        
        let iconImageView = UIImageView(image: UIImage(systemName: vaccine.icon))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = vaccine.color
        iconImageView.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = vaccine.rawValue
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = vaccine.color
        
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "In Stock"
        statusLabel.font = .systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = .secondaryLabel
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        
        container.addSubview(iconImageView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 70),
            
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    @objc private func directionsButtonTapped() {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func callButtonTapped() {
        guard let phoneNumber = location.phoneNumber,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
}
