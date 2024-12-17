//
//  RestaurantDetailServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Combine
import Foundation
import Domain

public protocol RestaurantDetailServiceProtocol {
    func fetchRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, Error>
    func fetchPhotoURL(photoReference: String) -> AnyPublisher<URL, Error>
}
