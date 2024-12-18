//
//  SearchPlaceViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Foundation
import Combine
import Domain
import Data

public class SearchPlaceViewModel {
    private let searchPlaceUseCase: SearchPlaceUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var placePredictions: [PlacePrediction]?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(searchPlaceUseCase: SearchPlaceUseCaseProtocol) {
        self.searchPlaceUseCase = searchPlaceUseCase
    }
    
    // 장소 자동 완성 응답 가져오기
    func fetchPlacePrediction(query: String) {
        searchPlaceUseCase.fetchPlacePrediction(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch nearby restaurants: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] placePredictions in
                self?.placePredictions = placePredictions
            })
            .store(in: &cancellables)
    }
}
