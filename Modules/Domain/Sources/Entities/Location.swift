//
//  LocationService.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import CoreData

public struct Location: Decodable {
    let lat: Double
    let lng: Double
    let address: String?
    
    public init(latitude: Double, longitude: Double, address: String? = nil) {
        self.lat = latitude
        self.lng = longitude
        self.address = address
    }
    
    public func getLatitude() -> Double {
        return lat
    }
    
    public func getLongitude() -> Double {
        return lng
    }
    
    public func getAddress() -> String? {
        return address
    }
}
