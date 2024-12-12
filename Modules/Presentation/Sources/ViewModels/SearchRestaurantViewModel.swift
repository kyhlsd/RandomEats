//
//  NearbyRestaurantViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Foundation
import Combine
import Domain

public class SearchRestaurantViewModel {
    private let nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol
    private let restaurantDetailUseCase: RestaurantDetailUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var restaurants: [String]?
    @Published var errorMessage: String?
    @Published var restaurantDetail: PlaceDetail?
    
    // UseCase 주입
    public init(nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol, restaurantDetailUseCase: RestaurantDetailUseCaseProtocol) {
        self.nearbyRestaurantUseCase = nearbyRestaurantUseCase
        self.restaurantDetailUseCase = restaurantDetailUseCase
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
            })
            .store(in: &cancellables)
    }
    
    // 식당 세부 정보 받아오는 함수
    func fetchRestaurantDetail(placeId: String) {
        restaurantDetailUseCase.getRestaurantDetail(placeId: placeId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch restaurant detail: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedRestaurantDetail in
                self?.restaurantDetail = fetchedRestaurantDetail
                print(self?.restaurantDetail ?? "detail is nil")
            })
            .store(in: &cancellables)
    }
}
