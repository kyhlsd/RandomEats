//
//  LocationRepository.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Combine

public protocol LocationRepositoryProtocol {
    func fetchCurrentLocation() async throws -> Location
    func fetchPreviousLocation() -> AnyPublisher<Location, Error>
    func updateCoreDataLocation(location: Location)
}
