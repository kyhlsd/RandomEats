//
//  ReverseGeocodingUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation
import Combine

public protocol ReverseGeocodingUseCaseProtocol {
    func getReverseGeocodedAddress(latitude: Double, longitude: Double) -> AnyPublisher<String, any Error>
    func fetchPreviousAddress() -> AnyPublisher<String, Error>
    func updateCoreDataAddress(address: String) -> AnyPublisher<Void, Error>
}

public class ReverseGeocodingUseCase: ReverseGeocodingUseCaseProtocol {
    private let reverseGeocodingRepository: ReverseGeocodingRepositoryProtocol
    
    public init(reverseGeocodingRepository: ReverseGeocodingRepositoryProtocol) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }
    
    public func getReverseGeocodedAddress(latitude: Double, longitude: Double) -> AnyPublisher<String, any Error> {
        return reverseGeocodingRepository.fetchAddress(from: latitude, longitude: longitude)
    }
    
    public func fetchPreviousAddress() -> AnyPublisher<String, any Error> {
        return reverseGeocodingRepository.fetchPreviousAddress()
    }
    
    public func updateCoreDataAddress(address: String) -> AnyPublisher<Void, Error> {
        return reverseGeocodingRepository.updateCoreDataAddress(address: address)
    }
}
