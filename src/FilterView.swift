//
//  FilterView.swift
//  WC Vax
//
//  Floating filter bar for vaccine types
//

import UIKit

protocol FilterViewDelegate: AnyObject {
    func filterView(_ filterView: FilterView, didSelectFilters filters: Set<VaccineType>)
}

class FilterView: UIView {
    
    weak var delegate: FilterViewDelegate?
    
    private var selectedFilters: Set<VaccineType> = Set(VaccineType.allCases) {
        didSet {
            delegate?.filterView(self, didSelectFilters: selectedFilters)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filter by Vaccine"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("All", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.setTitleColor(.systemTeal, for: .normal)
        button.addTarget(self, action: #selector(showAllButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonControlStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [showAllButton, clearButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.1
        
        addSubview(titleLabel)
        addSubview(buttonControlStack)
        addSubview(filterStackView)
        
        // Create filter buttons for each vaccine type
        for vaccineType in VaccineType.allCases {
            let button = createFilterButton(for: vaccineType)
            filterStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            buttonControlStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            buttonControlStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            filterStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            filterStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            filterStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            filterStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createFilterButton(for vaccineType: VaccineType) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = VaccineType.allCases.firstIndex(of: vaccineType) ?? 0
        button.setTitle(vaccineType.rawValue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        updateButtonAppearance(button, for: vaccineType, isSelected: true)
        
        return button
    }
    
    private func updateButtonAppearance(_ button: UIButton, for vaccineType: VaccineType, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = vaccineType.color
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor.secondarySystemFill
            button.setTitleColor(.secondaryLabel, for: .normal)
        }
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let vaccineType = VaccineType.allCases[sender.tag]
        
        if selectedFilters.contains(vaccineType) {
            selectedFilters.remove(vaccineType)
        } else {
            selectedFilters.insert(vaccineType)
        }
        
        updateButtonAppearance(sender, for: vaccineType, isSelected: selectedFilters.contains(vaccineType))
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
    
    @objc private func clearButtonTapped() {
        selectedFilters.removeAll()
        
        for (index, view) in filterStackView.arrangedSubviews.enumerated() {
            if let button = view as? UIButton {
                let vaccineType = VaccineType.allCases[index]
                updateButtonAppearance(button, for: vaccineType, isSelected: false)
            }
        }
    }
    
    @objc private func showAllButtonTapped() {
        selectedFilters = Set(VaccineType.allCases)
        
        for (index, view) in filterStackView.arrangedSubviews.enumerated() {
            if let button = view as? UIButton {
                let vaccineType = VaccineType.allCases[index]
                updateButtonAppearance(button, for: vaccineType, isSelected: true)
            }
        }
    }
}
