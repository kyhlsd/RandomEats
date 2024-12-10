//
//  NearbyRestaurantViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Foundation
import Combine
import Domain

public class NearbyRestaurantViewModel {
    private let nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol
    @Published var restaurants: [String]?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol) {
        self.nearbyRestaurantUseCase = nearbyRestaurantUseCase
    }
    
    // 주변 식당을 받아오는 함수
    func fetchNearbyRestaurant(for location: Location) {
        Task {
            do {
                let fetchedRestaurant = try await nearbyRestaurantUseCase.getNearbyRestaurant(latitude: location.getLatitude(), longitude: location.getLongitude(), maximumDistance: 500)
                self.restaurants = fetchedRestaurant
                print(self.restaurants ?? "nil")
            } catch {
                self.errorMessage = "Failed to fetch nearby restaurants: \(error)"
            }
        }
    }
}
