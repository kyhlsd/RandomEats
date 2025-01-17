//
//  NearbyRestaurantServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Combine
import Foundation

public protocol NearbyRestaurantServiceProtocol {
    func fetchNearbyRestaurantID(latitude: Double, longitude: Double, maximumDistance: Int) -> AnyPublisher<[String], Error>
}
