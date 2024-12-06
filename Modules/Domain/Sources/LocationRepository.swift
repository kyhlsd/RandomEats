//
//  LocationRepository.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation

public protocol LocationRepositoryProtocol {
    func fetchCurrentLocation() async throws -> Location
}
