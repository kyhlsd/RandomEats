//
//  RestaurantDetailRepositoryImplementaion.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Combine
import Domain

public class RestaurantDetailRepositoryImplementation: RestaurantDetailRepositoryProtocol {
    private let restaurantDetailService: RestaurantDetailServiceProtocol
    
    public init(restaurantDetailService: RestaurantDetailServiceProtocol) {
        self.restaurantDetailService = restaurantDetailService
    }
    
    public func fetchRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, Error> {
        return restaurantDetailService.fetchRestaurantDetail(placeId: placeId)
    }
    
    
}