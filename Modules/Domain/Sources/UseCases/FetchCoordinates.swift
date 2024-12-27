//
//  FetchCoordinates.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Combine
import Foundation

public protocol FetchCoordinatesUseCaseProtocol {
    func fetchCoordinates(placeId: String) -> AnyPublisher<Location, any Error>
}

public class FetchCoordinatesUseCase: FetchCoordinatesUseCaseProtocol {
    private let fetchCoordinatesRepository: FetchCoordinatesRepositoryProtocol

    public init(fetchCoordinatesRepository: FetchCoordinatesRepositoryProtocol) {
        self.fetchCoordinatesRepository = fetchCoordinatesRepository
    }

    public func fetchCoordinates(placeId: String) -> AnyPublisher<Location, any Error> {
        return fetchCoordinatesRepository.fetchCoordinates(placeId: placeId)
    }
}
