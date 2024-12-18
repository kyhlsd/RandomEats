//
//  SearchPlaceRepositoryProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Combine
import Foundation

public protocol SearchPlaceRepositoryProtocol {
    func fetchPlacePrediction(query: String) -> AnyPublisher<[PlacePrediction], any Error>
}
