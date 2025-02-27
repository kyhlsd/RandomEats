//
//  NearbyRestaurantRepositoryImplementation.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//
import Combine
import Domain

public class NearbyRestaurantRepositoryImplementation: NearbyRestaurantRepositoryProtocol {
    private let nearbyRestaurantService: NearbyRestaurantServiceProtocol
    
    public init(nearbyRestaurantService: NearbyRestaurantServiceProtocol) {
        self.nearbyRestaurantService = nearbyRestaurantService
    }
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) -> AnyPublisher<[PlaceForNearbySearch], Error> {
        return nearbyRestaurantService.fetchNearbyRestaurant(latitude: latitude, longitude: longitude, maximumDistance: maximumDistance)
    }
    
    
}
