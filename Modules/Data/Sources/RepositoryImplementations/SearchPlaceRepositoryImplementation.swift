//
//  PlaceSearchRepository.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Combine
import Domain

public class SearchPlaceRepositoryImplementation: SearchPlaceRepositoryProtocol {
    private let searchPlaceService: SearchPlaceServiceProtocol
    
    public init(searchPlacetService: SearchPlaceServiceProtocol) {
        self.searchPlaceService = searchPlacetService
    }
    
    public func fetchPlacePrediction(query: String) -> AnyPublisher<[PlacePrediction], any Error> {
        return searchPlaceService.fetchPlacePrediction(query: query)
    }
    
}
