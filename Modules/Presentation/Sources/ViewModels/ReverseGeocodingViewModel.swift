//
//  ReverseGeocodingViewModel.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation
import Combine
import Domain

public class ReverseGeocodingViewModel {
    private let reverseGeocodingUseCase: ReverseGeocodingUseCaseProtocol
    @Published var address: String?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(reverseGeocodingUseCase: ReverseGeocodingUseCaseProtocol) {
        self.reverseGeocodingUseCase = reverseGeocodingUseCase
    }
    
    // 위도와 경도를 주소로 변환하는 함수
    func fetchAddress(for location: Location) {
        Task {
            do {
                let fetchedAddress = try await reverseGeocodingUseCase.getReverseGeocodedAddress(latitude: location.getLatitude(), longitude: location.getLongitude())
                self.address = fetchedAddress
            } catch {
                self.errorMessage = "Failed to fetch address: \(error)"
            }
        }
    }
}
