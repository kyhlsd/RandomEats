//
//  ReverseGeocodingServiceImplementaion.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import CoreLocation
import GooglePlaces

public class ReverseGeocodingServiceImplementaion: ReverseGeocodingServiceProtocol {
    private let geocoder = CLGeocoder()
    
    public init() {}
    
    public func fetchAddress(latitude: Double, longitude: Double) async throws -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: NSError(domain: "Geocoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get address"]))
                    return
                }
                
                var address = ""
                
                if let locality = placemark.locality {
                    address += locality
                }
                
                if let subLocality = placemark.subLocality {
                    address += " " + subLocality
                }
                
                continuation.resume(returning: address)
            }
        }
    }
    
    
}
