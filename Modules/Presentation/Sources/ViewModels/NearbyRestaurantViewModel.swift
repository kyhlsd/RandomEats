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
    private var cancellables = Set<AnyCancellable>()
    
    @Published var restaurants: [String]?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol) {
        self.nearbyRestaurantUseCase = nearbyRestaurantUseCase
    }
    
    // 주변 식당을 받아오는 함수
    func fetchNearbyRestaurant(for location: Location, maximumDistance: Int) {
        nearbyRestaurantUseCase.getNearbyRestaurant(latitude: location.getLatitude(), longitude: location.getLongitude(), maximumDistance: maximumDistance)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch nearby restaurants: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedRestaurants in
                self?.restaurants = fetchedRestaurants
                print("FetchedRestaurants: \(fetchedRestaurants)")
            })
            .store(in: &cancellables)
    }
}
