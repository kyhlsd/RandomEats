//
//  ReverseGeocodingResponse.swift
//  Data
//
//  Created by 김영훈 on 12/28/24.
//

import Foundation

struct ReverseGeocodingResponse: Decodable {
    let results: [GeocodingResult]
}

struct GeocodingResult: Decodable {
    let formattedAddress: String

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}
