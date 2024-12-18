//
//  PlacesSearchResponse.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Foundation

// Google Places API 응답 모델 정의
public struct PlacesNearbySearchResponse: Decodable {
    public let results: [PlaceForNearbySearch]
    public let next_page_token: String?
}

public struct PlaceForNearbySearch: Decodable {
    public let place_id: String
}

public struct PlaceDetailSearchResponse: Decodable {
    public let result: PlaceDetail
}

public struct PlaceDetail: Decodable {
    public let name: String
    public let geometry: Geometry
    public let url: String
    public let rating: Double?
    public let user_ratings_total: Int?
    public let photos: [Photo]?
    
    public struct Geometry: Decodable {
        public let location: Location
    }
    
    public struct Photo: Decodable {
        public let photo_reference: String
    }
}
