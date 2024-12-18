//
//  PlacePrediction.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Foundation

public struct PlacesAutoCompleteResponse: Codable {
    public let predictions: [PlacePrediction]
}

public struct PlacePrediction: Codable {
    public let description: String
    public let place_id: String
}
