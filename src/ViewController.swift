//
//  ViewController.swift
//  WC Vax
//
//  Created by Treydon York on 4/25/21.
//
import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var mapView: MKMapView!
    private var hasInitiallyCentered = false
    
    private let manager = CLLocationManager()
    private var allLocations: [VaccineLocation] = []
    private var activeFilters: Set<VaccineType> = Set(VaccineType.allCases)
    private var selectedLocation: VaccineLocation?
    
    // UI Components
    private lazy var filterView: FilterView = {
        let view = FilterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.alpha = 0
        return view
    }()
    
    private lazy var recenterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemTeal
        button.tintColor = .white
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
        button.addTarget(self, action: #selector(recenterButtonTapped), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    private lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBackground
        button.tintColor = .systemTeal
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
        button.addTarget(self, action: #selector(showListView), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    private var detailViewBottomConstraint: NSLayoutConstraint?
    private var currentDetailView: LocationDetailView?
    
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMapView()
        setupLocationManager()
        setupNavigationBar()
        loadVaccineLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocationUpdatesIfAuthorized()
        animateUIAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar for full-screen map experience
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show navigation bar when leaving this view
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Create map view FIRST so it's behind everything
        let mv = MKMapView(frame: .zero)
        mv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mv)
        self.mapView = mv
        
        // Now add UI elements on top
        view.addSubview(filterView)
        view.addSubview(recenterButton)
        view.addSubview(listButton)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            // Map view fills entire screen
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Filter view on top - make room for list button
            filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterView.trailingAnchor.constraint(equalTo: listButton.leadingAnchor, constant: -8),
            
            // List button at top right
            listButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            listButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            listButton.widthAnchor.constraint(equalToConstant: 56),
            listButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Recenter button on bottom right
            recenterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recenterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            recenterButton.widthAnchor.constraint(equalToConstant: 56),
            recenterButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Loading view on top of everything
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        
        // Modern map configuration
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        }
        
        // Register custom annotation view
        mapView.register(VaccineAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    private func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            startLocationUpdatesIfAuthorized()
        }
    }
    
    private func setupNavigationBar() {
        // Navigation bar is hidden in viewWillAppear, but we keep this for when
        // returning from list view
        title = "Vaccine Finder"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Animation
    
    private func animateUIAppearance() {
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.filterView.alpha = 1
            self.filterView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.listButton.alpha = 1
            self.listButton.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.recenterButton.alpha = 1
            self.recenterButton.transform = .identity
        }
    }
    
    // MARK: - Data Loading
    
    private func loadVaccineLocations() {
        allLocations = [
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.828500, longitude: -84.890140),
                title: "Midtown MediCenter Pharmacy",
                vaccines: [.moderna, .johnsonJohnson],
                phoneNumber: "7659628000",
                address: "1401 Chester Blvd, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.828650, longitude: -84.893540),
                title: "Wayne County Health Department",
                vaccines: [.moderna, .johnsonJohnson],
                phoneNumber: "7659357650",
                address: "401 E Main St, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.862750, longitude: -84.883750),
                title: "Reid Health-Richmond",
                vaccines: [.moderna, .pfizer, .johnsonJohnson],
                phoneNumber: "7659833561",
                address: "1100 Reid Pkwy, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.868110, longitude: -84.885950),
                title: "Meijer",
                vaccines: [.moderna],
                phoneNumber: "7659621200",
                address: "3100 E Main St, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.826670, longitude: -84.853290),
                title: "Walmart",
                vaccines: [.johnsonJohnson],
                phoneNumber: "7659398311",
                address: "4300 S 7th St, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.831600, longitude: -84.851040),
                title: "Walgreens",
                vaccines: [.moderna, .johnsonJohnson],
                phoneNumber: "7659622631",
                address: "901 National Rd W, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.829300, longitude: -84.850660),
                title: "Kroger Pharmacy",
                vaccines: [.moderna, .johnsonJohnson],
                phoneNumber: "7659628900",
                address: "2350 Chester Blvd, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.862360, longitude: -84.889590),
                title: "CVS Pharmacy-Richmond",
                vaccines: [.johnsonJohnson],
                phoneNumber: "7659668400",
                address: "1201 E Main St, Richmond, IN 47374"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.816650, longitude: -85.154970),
                title: "CVS Pharmacy-Cambridge City",
                vaccines: [.johnsonJohnson],
                phoneNumber: "7654785100",
                address: "110 S Foote St, Cambridge City, IN 47327"
            ),
            VaccineLocation(
                coordinate: CLLocationCoordinate2D(latitude: 39.813690, longitude: -85.171120),
                title: "MediCenter Pharmacy Alt.",
                vaccines: [.johnsonJohnson],
                phoneNumber: "7654785678",
                address: "Cambridge City Health Center, IN 47327"
            )
        ]
    }
    
    // MARK: - Location Updates
    
    private func startLocationUpdatesIfAuthorized() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            manager.startUpdatingLocation()
        case .notDetermined, .restricted, .denied:
            // Show default region if location denied
            showDefaultRegion()
            updateMapAnnotations() // Add annotations even if location denied
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadingView.dismiss()
            }
            break
        @unknown default:
            break
        }
    }
    
    private func showDefaultRegion() {
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.840, longitude: -84.890)
        centerMap(on: defaultCoordinate, animated: false)
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool) {
        guard let mapView = mapView else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    // MARK: - Actions
    
    @objc private func recenterButtonTapped() {
        if let userLocation = mapView.userLocation.location {
            centerMap(on: userLocation.coordinate, animated: true)
            
            // Pulse animation
            UIView.animate(withDuration: 0.1, animations: {
                self.recenterButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.recenterButton.transform = .identity
                }
            }
        }
    }
    
    @objc private func showListView() {
        let listVC = LocationListViewController(locations: allLocations)
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    // MARK: - Annotation Management
    
    private func updateMapAnnotations() {
        guard let mapView = mapView else { return }
        
        // Remove all existing annotations except user location
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Add filtered locations
        let filteredLocations = allLocations.filter { location in
            !Set(location.vaccines).isDisjoint(with: activeFilters)
        }
        
        mapView.addAnnotations(filteredLocations)
    }
    
    // MARK: - Detail View Management
    
    private func showDetailView(for location: VaccineLocation) {
        // Remove existing detail view
        hideDetailView()
        
        let detailView = LocationDetailView(location: location)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailView)
        
        let bottomConstraint = detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        
        NSLayoutConstraint.activate([
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
        ])
        
        self.currentDetailView = detailView
        self.detailViewBottomConstraint = bottomConstraint
        
        view.layoutIfNeeded()
        
        // Animate in
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDetailViewTap))
        tapGesture.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleDetailViewTap() {
        hideDetailView()
    }
    
    private func hideDetailView() {
        guard let detailView = currentDetailView,
              let bottomConstraint = detailViewBottomConstraint else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            bottomConstraint.constant = 400
            self.view.layoutIfNeeded()
        }) { _ in
            detailView.removeFromSuperview()
            self.currentDetailView = nil
            self.detailViewBottomConstraint = nil
            
            // Remove tap gestures
            self.mapView.gestureRecognizers?.forEach { gesture in
                if gesture is UITapGestureRecognizer {
                    self.mapView.removeGestureRecognizer(gesture)
                }
            }
        }
        
        // Deselect annotation
        if let selected = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(selected, animated: true)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startLocationUpdatesIfAuthorized()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationUpdatesIfAuthorized()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Only center once on first location update
        if !hasInitiallyCentered {
            centerMap(on: location.coordinate, animated: true)
            updateMapAnnotations()
            hasInitiallyCentered = true
            
            // Dismiss loading view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadingView.dismiss()
            }
        }
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        showDefaultRegion()
        updateMapAnnotations()
        
        // Dismiss loading view even on error
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadingView.dismiss()
        }
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let vaccineLocation = annotation as? VaccineLocation else {
            return nil
        }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? VaccineAnnotationView
        view?.annotation = vaccineLocation
        view?.canShowCallout = false
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let vaccineLocation = view.annotation as? VaccineLocation else { return }
        
        // Animate selection
        if let annotationView = view as? VaccineAnnotationView {
            annotationView.animateSelection()
        }
        
        // Show detail view
        showDetailView(for: vaccineLocation)
        
        // Center map on annotation with offset for detail view
        let coordinate = vaccineLocation.coordinate
        let offsetCoordinate = CLLocationCoordinate2D(
            latitude: coordinate.latitude + 0.02,
            longitude: coordinate.longitude
        )
        
        let region = MKCoordinateRegion(
            center: offsetCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Detail view dismissal is handled by tap gesture
    }
}

// MARK: - FilterViewDelegate

extension ViewController: FilterViewDelegate {
    
    func filterView(_ filterView: FilterView, didSelectFilters filters: Set<VaccineType>) {
        activeFilters = filters
        updateMapAnnotations()
        hideDetailView()
    }
}

