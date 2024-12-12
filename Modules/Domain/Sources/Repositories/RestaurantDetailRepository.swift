//
//  RestaurantDetailRepository.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Combine
import Foundation

public protocol RestaurantDetailRepositoryProtocol {
    func fetchRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, Error>
}
