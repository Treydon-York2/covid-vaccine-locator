//
//  LocationListViewController.swift
//  WC Vax
//
//  List view of vaccine locations
//

import UIKit
import MapKit

class LocationListViewController: UIViewController {
    
    private var locations: [VaccineLocation]
    private var filteredLocations: [VaccineLocation] = []
    private var activeFilters: Set<VaccineType> = Set(VaccineType.allCases)
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationCell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }()
    
    private lazy var filterView: FilterView = {
        let view = FilterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    init(locations: [VaccineLocation]) {
        self.locations = locations
        self.filteredLocations = locations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = "Locations"
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(filterView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateFilteredLocations() {
        filteredLocations = locations.filter { location in
            !Set(location.vaccines).isDisjoint(with: activeFilters)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension LocationListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        cell.configure(with: filteredLocations[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LocationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let location = filteredLocations[indexPath.row]
        let detailVC = LocationDetailViewController(location: location)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - FilterViewDelegate

extension LocationListViewController: FilterViewDelegate {
    
    func filterView(_ filterView: FilterView, didSelectFilters filters: Set<VaccineType>) {
        activeFilters = filters
        updateFilteredLocations()
    }
}

// MARK: - LocationTableViewCell

class LocationTableViewCell: UITableViewCell {
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var vaccinesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(vaccinesStackView)
        cardView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            vaccinesStackView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12),
            vaccinesStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            vaccinesStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            vaccinesStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with location: VaccineLocation) {
        nameLabel.text = location.title
        addressLabel.text = location.address ?? "Address not available"
        
        // Clear previous vaccine badges
        vaccinesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add vaccine badges
        for vaccine in location.vaccines {
            let badge = createVaccineBadge(for: vaccine)
            vaccinesStackView.addArrangedSubview(badge)
        }
    }
    
    private func createVaccineBadge(for vaccine: VaccineType) -> UIView {
        let container = UIView()
        container.backgroundColor = vaccine.color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 8
        
        let iconImageView = UIImageView(image: UIImage(systemName: vaccine.icon))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = vaccine.color
        iconImageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = vaccine.rawValue
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = vaccine.color
        
        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalToConstant: 14),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        
        return container
    }
}

// MARK: - LocationDetailViewController

class LocationDetailViewController: UIViewController {
    
    private let location: VaccineLocation
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    init(location: VaccineLocation) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = location.title
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Add content
        addInfoSection()
        addVaccineSection()
        addActionButtons()
    }
    
    private func addInfoSection() {
        let addressLabel = UILabel()
        addressLabel.text = location.address ?? "Address not available"
        addressLabel.font = .systemFont(ofSize: 16, weight: .regular)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        
        contentStack.addArrangedSubview(addressLabel)
    }
    
    private func addVaccineSection() {
        let titleLabel = UILabel()
        titleLabel.text = "Available Vaccines"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        contentStack.addArrangedSubview(titleLabel)
        
        // Add vaccine badges
        for vaccine in location.vaccines {
            let badge = createVaccineBadge(for: vaccine)
            contentStack.addArrangedSubview(badge)
        }
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
    
    private func addActionButtons() {
        let directionsButton = createActionButton(
            title: "Get Directions",
            icon: "arrow.triangle.turn.up.right.diamond.fill",
            color: .systemTeal,
            action: #selector(getDirections)
        )
        
        contentStack.addArrangedSubview(directionsButton)
        
        if location.phoneNumber != nil {
            let callButton = createActionButton(
                title: "Call",
                icon: "phone.fill",
                color: .systemGreen,
                action: #selector(callLocation)
            )
            contentStack.addArrangedSubview(callButton)
        }
    }
    
    private func createActionButton(title: String, icon: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.backgroundColor = color
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    @objc private func getDirections() {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func callLocation() {
        guard let phoneNumber = location.phoneNumber,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
}

