//
//  LocationViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Combine
import Domain

protocol LocationViewModelDelegate: AnyObject {
    func setLocationWithSearchResult(searchedLocation: Location)
}

public class LocationViewModel {
    private let locationUseCase: LocationUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var location: Location?
    @Published var errorMessage: String?
    
    var isAddressUpdateNeeded = false
    
    // UseCase 주입
    public init(locationUseCase: LocationUseCaseProtocol) {
        self.locationUseCase = locationUseCase
    }
    
    // 현재 위치를 가져오는 함수
    func fetchCurrentLocation() {
        locationUseCase.getCurrentLocation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case LocationServiceError.permissionDenied:
                        self?.errorMessage = LocationServiceError.permissionDenied.errorDescription
                    case LocationServiceError.permissionRestricted:
                        self?.errorMessage = LocationServiceError.permissionRestricted.errorDescription
                    default:
                        self?.errorMessage = LocationServiceError.unknownError.errorDescription
                    }
                    self?.errorMessage = "\(LocationServiceError.unknownError.errorDescription ?? "Failed to fetch location"): \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.location = location
            })
            .store(in: &cancellables)
    }
    
    func fetchPreviousLocation() {
        locationUseCase.fetchPreviousLocation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch previous location: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.location = location
            })
            .store(in: &cancellables)
    }
    
    func updateCoreDataLocation(location: Location) {
        locationUseCase.updateCoreDataLocation(location: location)
    }
}

extension LocationViewModel: LocationViewModelDelegate {
    func setLocationWithSearchResult(searchedLocation: Location) {
        isAddressUpdateNeeded = false
        location = searchedLocation
    }
}
