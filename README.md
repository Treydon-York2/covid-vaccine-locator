COVID-19 Vaccination Locator App (iOS)

OVERVIEW:
This project involved the development of a native iOS application in Swift using Xcode to help users locate nearby COVID-19 vaccination clinics. The application integrated real-time GPS data and Apple Maps navigation to provide accessible, location-based healthcare resources during the COVID-19 pandemic.

The application was published through my county health department and reached over 5,000 active users within three months.

MOTIVATION:
During the COVID-19 vaccine rollout, timely access to accurate clinic locations was critical, especially in rural areas that were access-limited. This application was designed to provide a simple, location-aware interface allowing users to identify the nearest vaccination sites, which vaccines were offered, and receive direct navigation instructions.

CORE FEATURES:
* GPS-based clinic discovery using Core Location
* Apple Maps API integration for real-time navigation
* Manually maintained structured clinic database
* User-friendly, minimal UI design
* Location permission handling and privacy compliance

SYSTEM ARCHITECTURE:
The application follows a modular structure -

* LocationManager: Handles GPS retrieval and permission flow
* Clinic Data Model: Stores structured clinic information
* Main ViewController: Manages UI rendering and list display
* Map Integration Logic: Interfaces with Apple Maps for routing

TECHNOLOGIES USED:
* Swift
* Xcode
* Core Location Framework
* Apple Maps API
* UIKit

IMPLEMENTATION DETAILS:
User location is retrieved through Core Location services with appropriate permission handling. The application compares the user’s coordinates against a structured list of vaccination clinic locations and dynamically presents nearby options.

Upon user selection, Apple Maps is launched with pre-filled routing information to provide real-time navigation.

Clinic location data was manually maintained and updated to ensure reliability and accuracy during deployment.

VALIDATION & DEPLOYMENT:
The application was tested across multiple device configurations to validate - 

* GPS accuracy testing
* Route validation via Apple Maps
* Structured data verification
* UI responsiveness testing across devices

KEY TAKEAWAYS:

* Strengthened native iOS development skills using UIKit
* Integrated System-level API's for real-time geolocation and mapping
* Managed structured local data models for dynamic UI rendering
* Delivered a publicly deployed application with measurable user impact
