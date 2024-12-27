//
//  FetchCoordinatesRepositoryImplementation.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Combine
import Domain

public class FetchCoordinatesRepositoryImplementation: FetchCoordinatesRepositoryProtocol {
    
    private let fetchCoordinatesService: FetchCoordinatesServiceProtocol
    
    public init(fetchCoordinatesService: FetchCoordinatesServiceProtocol) {
        self.fetchCoordinatesService = fetchCoordinatesService
    }
    
    public func fetchCoordinates(placeId: String) -> AnyPublisher<Location, any Error> {
        return fetchCoordinatesService.fetchCoordinates(placeId: placeId)
    }
    
}
