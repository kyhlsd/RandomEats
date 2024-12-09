//
//  ReverseGeocodingUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation

public protocol ReverseGeocodingUseCaseProtocol {
    func getReverseGeocodedAddress(latitude: Double, longitude: Double) async throws -> String
}

public class ReverseGeocodingUseCase: ReverseGeocodingUseCaseProtocol {
    private let reverseGeocodingRepository: ReverseGeocodingRepositoryProtocol
    
    public init(reverseGeocodingRepository: ReverseGeocodingRepositoryProtocol) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }
    
    public func getReverseGeocodedAddress(latitude: Double, longitude: Double) async throws -> String {
        return try await reverseGeocodingRepository.getAddress(from: latitude, longitude: longitude)
    }
}
