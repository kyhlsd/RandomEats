//
//  LocationRepositoryImplementation.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import CoreLocation
import Domain

public class LocationRepositoryImplementation: LocationRepositoryProtocol {
    private let locationService: LocationServiceProtocol

    public init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    public func fetchCurrentLocation() async throws -> Location {
        return try await locationService.fetchCurrentLocation()
    }
}
