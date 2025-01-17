//
//  NearbyRestaurantViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Foundation
import Combine
import Domain

public class SearchRestaurantViewModel {
    private let nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol
    private let restaurantDetailUseCase: RestaurantDetailUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var restaurants: [String]?
    @Published var errorMessage: String?
    @Published var restaurantDetail: PlaceDetail?
    @Published var photoURL: URL?
    @Published var bestRestaurantDetails: [PlaceDetail]?
    
    // UseCase 주입
    public init(nearbyRestaurantUseCase: NearbyRestaurantUseCaseProtocol, restaurantDetailUseCase: RestaurantDetailUseCaseProtocol) {
        self.nearbyRestaurantUseCase = nearbyRestaurantUseCase
        self.restaurantDetailUseCase = restaurantDetailUseCase
    }
    
    // 주변 식당을 받아오는 함수
    func fetchNearbyRestaurantID(for location: Location, maximumDistance: Int) {
        nearbyRestaurantUseCase.getNearbyRestaurantID(latitude: location.getLatitude(), longitude: location.getLongitude(), maximumDistance: maximumDistance)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch nearby restaurants: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedRestaurants in
                self?.restaurants = fetchedRestaurants
            })
            .store(in: &cancellables)
    }
    
    // 식당 세부 정보 받아오는 함수
    func fetchRestaurantDetail(placeId: String) {
        restaurantDetailUseCase.getRestaurantDetail(placeId: placeId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch restaurant detail: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedRestaurantDetail in
                self?.restaurantDetail = fetchedRestaurantDetail
                self?.fetchPhotoURL()
            })
            .store(in: &cancellables)
    }
    
    // best 식당 5개의 정보를 받아오는 함수
    func fetchBestRestaurantDetails(placeIDs: [String]) {
        
        let detailPublishers = placeIDs.map { placeID in
            restaurantDetailUseCase.getRestaurantDetail(placeId: placeID)
        }
        
        Publishers.MergeMany(detailPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch best restaurants details: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedDetails in
                self?.bestRestaurantDetails = fetchedDetails
            })
            .store(in: &cancellables)
    }
    
    // 식당 이미지 레퍼렌스로 이미지 불러오는 함수
    func fetchPhotoURL() {
        if let photoReference = restaurantDetail?.photos?.first?.photo_reference {
            restaurantDetailUseCase.getPhotoURL(photoReference: photoReference)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = "Failed to fetch photo URL: \(error)"
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] fetchedPhotoURL in
                    self?.photoURL = fetchedPhotoURL
                })
                .store(in: &cancellables)
        } else {
            photoURL = nil
        }
        return
    }
}
