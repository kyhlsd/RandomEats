//
//  NearbyRestaurantServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Foundation

public protocol NearbyRestaurantServiceProtocol {
    func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String]
}
