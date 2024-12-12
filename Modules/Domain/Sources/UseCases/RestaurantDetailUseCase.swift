//
//  RestaurantDetailUseCaseProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Combine
import Foundation

public protocol RestaurantDetailUseCaseProtocol {
    func getRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, Error>
}

public class RestaurantDetailUseCase: RestaurantDetailUseCaseProtocol {
    private let restaurantDetailRepository: RestaurantDetailRepositoryProtocol

    public init(restaurantDetailRepository: RestaurantDetailRepositoryProtocol) {
        self.restaurantDetailRepository = restaurantDetailRepository
    }

    public func getRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, Error> {
        return restaurantDetailRepository.fetchRestaurantDetail(placeId: placeId)
    }
}
