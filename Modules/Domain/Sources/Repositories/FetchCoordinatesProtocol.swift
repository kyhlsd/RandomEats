//
//  FetchCoordinatesProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Combine
import Foundation

public protocol FetchCoordinatesRepositoryProtocol {
    func fetchCoordinates(placeId: String) -> AnyPublisher<Location, Error>
}
