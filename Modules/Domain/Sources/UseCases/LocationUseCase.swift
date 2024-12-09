//
//  LocationUseCase.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation

public protocol LocationUseCaseProtocol {
    func getCurrentLocation() async throws -> Location
}

public class LocationUseCase: LocationUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol

    public init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    public func getCurrentLocation() async throws -> Location {
        return try await locationRepository.fetchCurrentLocation()
    }
}
