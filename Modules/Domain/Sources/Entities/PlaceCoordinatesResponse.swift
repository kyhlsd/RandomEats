//
//  PlaceDetailsResponse.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Foundation

public struct PlaceCoordinatesResponse: Decodable {
    public let result: Result
    
    public struct Result: Decodable {
        public let geometry: Geometry
        
        public struct Geometry: Decodable {
            public let location: Location
            
            public struct Location: Decodable {
                public let lat: Double?
                public let lng: Double?
            }
        }
    }
}
