//
//  NearbyRestaurantServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Combine
import Foundation
import Domain

public protocol NearbyRestaurantServiceProtocol {
    func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) -> AnyPublisher<[PlaceForNearbySearch], Error>
}
