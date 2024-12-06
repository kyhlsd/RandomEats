//
//  LocationServiceProtocol.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Domain

public protocol LocationServiceProtocol {
    func fetchCurrentLocation() async throws -> Location
}
