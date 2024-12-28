//
//  ReverseGeocodingRepositoryImplementation.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Combine
import Domain

public class ReverseGeocodingRepositoryImplementation: ReverseGeocodingRepositoryProtocol {
    private let reverseGeocodingService: ReverseGeocodingServiceProtocol
    
    public init(reverseGeocodingService: ReverseGeocodingServiceProtocol) {
        self.reverseGeocodingService = reverseGeocodingService
    }
    
    public func getAddress(from latitude: Double, longitude: Double) -> AnyPublisher<String, any Error>  {
        return reverseGeocodingService.fetchAddress(latitude: latitude, longitude: longitude)
    }
}
