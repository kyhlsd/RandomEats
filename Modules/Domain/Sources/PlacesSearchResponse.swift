//
//  PlacesSearchResponse.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Foundation

// Google Places API 응답 모델 정의
public struct PlacesSearchResponse: Decodable {
    let results: [Place]
    let next_page_token: String?
}

public struct Place: Decodable {
    let name: String
}
