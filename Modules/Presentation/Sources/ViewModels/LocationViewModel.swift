//
//  LocationViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Combine
import Domain

public class LocationViewModel {
    private let locationUseCase: LocationUseCaseProtocol
    @Published var location: Location?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(locationUseCase: LocationUseCaseProtocol) {
        self.locationUseCase = locationUseCase
    }
    
    // 현재 위치를 가져오는 함수
    func fetchCurrentLocation() {
        Task {
            do {
                let fetchedLocation = try await locationUseCase.getCurrentLocation()
                self.location = fetchedLocation
            } catch {
                self.errorMessage = "Failed to get current location: \(error)"
            }
        }
    }
}


