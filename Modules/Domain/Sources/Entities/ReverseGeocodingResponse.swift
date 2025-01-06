//
//  ReverseGeocodingResponse.swift
//  Data
//
//  Created by 김영훈 on 12/28/24.
//

import Foundation

public struct ReverseGeocodingResponse: Decodable {
    public let results: [GeocodingResult]
}

public struct GeocodingResult: Decodable {
    public let formattedAddress: String

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}
