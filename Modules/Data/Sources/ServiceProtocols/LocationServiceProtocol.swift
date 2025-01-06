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
    func fetchCurrentLocation() async throws -> Location
    func fetchPreviousLocation() -> AnyPublisher<Location, any Error>
    func updateCoreDataLocation(location: Location)
}
