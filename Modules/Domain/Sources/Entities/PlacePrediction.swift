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
    public let placeId: String
    public let mainText: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case placeID = "place_id"
        case structuredFormatting = "structured_formatting"
    }
    
    enum StructuredFormattingKeys: String, CodingKey {
        case mainText = "main_text"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        
        self.placeId = try container.decode(String.self, forKey: .placeID)
        
        let structuredFormatting = try container.nestedContainer(keyedBy: StructuredFormattingKeys.self, forKey: .structuredFormatting)
        self.mainText = try structuredFormatting.decode(String.self, forKey: .mainText)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode(placeId, forKey: .placeID)
        
        var structuredFormatting = container.nestedContainer(keyedBy: StructuredFormattingKeys.self, forKey: .structuredFormatting)
        try structuredFormatting.encode(mainText, forKey: .mainText)
    }
}
