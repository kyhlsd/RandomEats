//
//  FetchCoordinatesServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Combine
import Foundation
import Domain

public protocol FetchCoordinatesServiceProtocol {
    func fetchCoordinates(placeId: String) -> AnyPublisher<Location, any Error>
}
