//
//  LocationServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Domain
import Combine

public protocol LocationServiceProtocol {
    func fetchCurrentLocation() -> AnyPublisher<Location, Error>
    func fetchPreviousLocation() -> AnyPublisher<Location, any Error>
    func updateCoreDataLocation(location: Location) -> AnyPublisher<Void, any Error>
}
