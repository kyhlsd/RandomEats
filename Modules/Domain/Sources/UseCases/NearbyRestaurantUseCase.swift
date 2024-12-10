//
//  NearbyRestaurantUseCase.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Foundation

public protocol NearbyRestaurantUseCaseProtocol {
    func getNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String]
}

public class NearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol {
    private let nearbyRestaurantRepository: NearbyRestaurantRepositoryProtocol

    public init(nearbyRestaurantRepository: NearbyRestaurantRepositoryProtocol) {
        self.nearbyRestaurantRepository = nearbyRestaurantRepository
    }

    public func getNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String] {
        return try await nearbyRestaurantRepository.fetchNearbyRestaurant(latitude: latitude, longitude: longitude, maximumDistance: maximumDistance)
    }
}
