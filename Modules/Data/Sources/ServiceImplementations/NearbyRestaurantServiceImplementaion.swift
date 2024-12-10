//
//  NearbyRestaurantServiceImplementaion.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import GooglePlaces

public class NearbyRestaurantServiceImplementaion: NearbyRestaurantServiceProtocol {

    private var placeResults: [GMSPlace] = []
    private let placeProperties = [GMSPlaceProperty.name].map { $0.rawValue }
    
    public init() {}
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String] {
        let circularLocationRestriction = GMSPlaceCircularLocationOption(CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), CLLocationDistance(maximumDistance))
        let request = GMSPlaceSearchNearbyRequest(locationRestriction: circularLocationRestriction, placeProperties: placeProperties)
        let includedTypes = ["restaurant"]
        request.includedTypes = includedTypes
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GMSPlacesClient.shared().searchNearby(with: request) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let results = results else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    let placeNames = results.map { $0.name ?? "Unnamed Restaurant" }
                    continuation.resume(returning: placeNames)
                }
            }
        }
    }
}
