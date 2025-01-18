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
    private var cancellables = Set<AnyCancellable>()
    
    @Published var address: String?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(reverseGeocodingUseCase: ReverseGeocodingUseCaseProtocol) {
        self.reverseGeocodingUseCase = reverseGeocodingUseCase
    }
    
    // 위도와 경도를 주소로 변환하는 함수
    func fetchAddress(for location: Location) {
        reverseGeocodingUseCase.getReverseGeocodedAddress(latitude: location.getLatitude(), longitude: location.getLongitude())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case APIError.invalidResponse:
                        self?.errorMessage = APIError.invalidResponse.errorDescription
                    case APIError.noInternetConnection:
                        self?.errorMessage = APIError.noInternetConnection.errorDescription
                    case APIError.serverError:
                        self?.errorMessage = APIError.serverError.errorDescription
                    default:
                        self?.errorMessage = APIError.unknownError(description: error.localizedDescription).errorDescription
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] address in
                self?.address = address
            })
            .store(in: &cancellables)
    }
    
    func fetchPreviousAddress() {
        reverseGeocodingUseCase.fetchPreviousAddress()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    // TODO: Coredata 에러 처리
                    self?.errorMessage = "Failed to fetch previous address: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] address in
                self?.address = address
            })
            .store(in: &cancellables)
    }
    
    func updateCoreDataAddress(address: String) {
        reverseGeocodingUseCase.updateCoreDataAddress(address: address)
    }
}
