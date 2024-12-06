//
//  LocationService.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation

public struct Location {
    let latitude: Double
    let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

