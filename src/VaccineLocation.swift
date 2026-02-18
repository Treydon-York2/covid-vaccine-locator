//
//  VaccineLocation.swift
//  WC Vax
//
//  Enhanced vaccine location model
//

import Foundation
import MapKit
import UIKit

enum VaccineType: String, CaseIterable {
    case moderna = "Moderna"
    case pfizer = "Pfizer"
    case johnsonJohnson = "Johnson & Johnson"
    
    var color: UIColor {
        switch self {
        case .moderna: return UIColor.systemIndigo
        case .pfizer: return UIColor.systemTeal
        case .johnsonJohnson: return UIColor.systemOrange
        }
    }
    
    var icon: String {
        switch self {
        case .moderna: return "cross.circle.fill"
        case .pfizer: return "cross.fill"
        case .johnsonJohnson: return "cross.case.fill"
        }
    }
}

class VaccineLocation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let vaccines: [VaccineType]
    let phoneNumber: String?
    let address: String?
    
    var primaryColor: UIColor {
        return vaccines.first?.color ?? .systemBlue
    }
    
    init(coordinate: CLLocationCoordinate2D,
         title: String,
         vaccines: [VaccineType],
         phoneNumber: String? = nil,
         address: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.vaccines = vaccines
        self.phoneNumber = phoneNumber
        self.address = address
        
        let vaccineNames = vaccines.map { $0.rawValue }.joined(separator: ", ")
        self.subtitle = "Available: \(vaccineNames)"
        
        super.init()
    }
}
