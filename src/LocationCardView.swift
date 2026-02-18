//
//  LocationCardView.swift
//  WC Vax
//
//  Swipeable card view for vaccine locations
//

import UIKit
import MapKit

class LocationCardView: UIView {
    
    private let location: VaccineLocation
    private weak var mapView: MKMapView?
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let distanceLabel = UILabel()
    private let vaccineStackView = UIStackView()
    private let directionsButton = UIButton(type: .system)
    
    init(location: VaccineLocation, mapView: MKMapView) {
        self.location = location
        self.mapView = mapView
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Container with blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
        addSubview(blurView)
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        layer.cornerRadius = 20
        backgroundColor = .clear
        
        // Content container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(containerView)
        
        setupTitle()
        setupSubtitle()
        setupDistance()
        setupVaccineChips()
        setupDirectionsButton()
        
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            distanceLabel,
            vaccineStackView,
            directionsButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .leading
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Add tap gesture to focus on map
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupTitle() {
        titleLabel.text = location.title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
    }
    
    private func setupSubtitle() {
        subtitleLabel.text = "Vaccine Provider"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
    }
    
    private func setupDistance() {
        // Distance calculation removed - not available in current VaccineLocation model
        // You can add it back by calculating distance from user's location if needed
        distanceLabel.isHidden = true
    }
    
    private func setupVaccineChips() {
        vaccineStackView.axis = .horizontal
        vaccineStackView.spacing = 8
        vaccineStackView.alignment = .leading
        vaccineStackView.distribution = .fillProportionally
        
        for vaccine in location.vaccines.prefix(3) {
            let chip = createVaccineChip(vaccine: vaccine)
            vaccineStackView.addArrangedSubview(chip)
        }
    }
    
    private func createVaccineChip(vaccine: VaccineType) -> UIView {
        let container = UIView()
        container.backgroundColor = vaccine.color.withAlphaComponent(0.2)
        container.layer.cornerRadius = 14
        
        let label = UILabel()
        label.text = vaccine.rawValue
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = vaccine.color
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        
        return container
    }
    
    private func setupDirectionsButton() {
        directionsButton.setTitle("Get Directions →", for: .normal)
        directionsButton.backgroundColor = .systemTeal
        directionsButton.setTitleColor(.white, for: .normal)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        directionsButton.layer.cornerRadius = 12
        directionsButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 28, bottom: 14, right: 28)
        directionsButton.addTarget(self, action: #selector(directionsButtonTapped), for: .touchUpInside)
        
        // Add width constraint
        directionsButton.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    }
    
    @objc private func cardTapped() {
        // Center map on this location
        guard let mapView = mapView else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // Select the annotation
        if let annotation = mapView.annotations.first(where: { ($0 as? VaccineLocation) === location }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    @objc private func directionsButtonTapped() {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
