//
//  SearchPlaceUseCase.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Combine
import Foundation

public protocol SearchPlaceUseCaseProtocol {
    func fetchPlacePrediction(query: String) -> AnyPublisher<[PlacePrediction], any Error>
}

public class SearchPlaceUseCase: SearchPlaceUseCaseProtocol {
    private let searchPlaceRepository: SearchPlaceRepositoryProtocol

    public init(searchPlaceRepository: SearchPlaceRepositoryProtocol) {
        self.searchPlaceRepository = searchPlaceRepository
    }

    public func fetchPlacePrediction(query: String) -> AnyPublisher<[PlacePrediction], any Error> {
        return searchPlaceRepository.fetchPlacePrediction(query: query)
    }
}
