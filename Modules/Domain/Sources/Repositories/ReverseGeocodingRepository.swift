//
//  AddressRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation

public protocol ReverseGeocodingRepositoryProtocol {
    func getAddress(from latitude: Double, longitude: Double) async throws -> String
}
