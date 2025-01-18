//
//  RestaurantMapViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 1/17/25.
//

import Foundation
import Combine
import Domain

public class RestaurantMapViewModel {
    let allowedDistances = [100, 200, 300, 400, 500]
    var currentLocation: Location?
    var bestRestaurantIDs: [String]?
    var selectedRestaurantIndex: Int? = nil
    private var restaurants: [PlaceDetail]? = nil
    var bestRestaurants: [PlaceDetail]?
    var shouldUpdateCurrentLocation = false
    private var cancellables = Set<AnyCancellable>()

    @Published var setLocation: Location?
    @Published var photoURLs: [String: URL?]?
    @Published var isFetching: Bool = false
    @Published var maximumDistance: Int = 300
    @Published var isConditionChanged = true
    @Published var errorMessage: String?
    
    
    let locationViewModel: LocationViewModel
    private let reverseGeocodingViewModel: ReverseGeocodingViewModel
    private let locationUseCase: LocationUseCaseProtocol
    private let searchRestaurantViewModel: SearchRestaurantViewModel
    public weak var delegate: CenterMapBetweenLocationsDelegate?

    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel, locationUseCase: LocationUseCaseProtocol, searchRestaurantViewModel: SearchRestaurantViewModel) {
        self.locationViewModel = locationViewModel
        self.reverseGeocodingViewModel = reverseGeocodingViewModel
        self.locationUseCase = locationUseCase
        self.searchRestaurantViewModel = searchRestaurantViewModel
        bindViewModels()
    }
    
    private func bindViewModels() {
        // 위치 업데이트 바인딩
        locationViewModel.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.setLocation = location
                self?.isConditionChanged = true
            }
            .store(in: &cancellables)
        
        // 주위 식당 placeID 바인딩
        searchRestaurantViewModel.$restaurants
            .compactMap { $0 }
            .sink { [weak self] restaurants in
                guard let self = self else { return }
                let totalAverageRating = calculateGlobalAverageRating(from: restaurants)
                self.bestRestaurantIDs = Array(restaurants
                    .sorted {
                        let score1 = self.calculatePopularityScore(reviews: $0.user_ratings_total ?? 0, rating: $0.rating ?? 0.0, totalAverageRating: totalAverageRating, k: 50)
                        let score2 = self.calculatePopularityScore(reviews: $1.user_ratings_total ?? 0, rating: $1.rating ?? 0.0, totalAverageRating: totalAverageRating, k: 50)
                        return score1 > score2
                    }
                    .prefix(5)
                )
                .map { $0.place_id }
                // 조건 추가
                self.fetchBestRestaurantDetails()
            }
            .store(in: &cancellables)
        
        searchRestaurantViewModel.$bestRestaurantDetails
            .compactMap { $0 }
            .sink { [weak self] restaurants in
                self?.bestRestaurants = restaurants
            }
            .store(in: &cancellables)
        
        searchRestaurantViewModel.$photoURLs
            .compactMap { $0 }
            .sink { [weak self] photoURLs in
                self?.photoURLs = photoURLs
                self?.isFetching = false
            }
            .store(in: &cancellables)
    }
    
    // 위치를 설정하는 경우
    func fetchCurrentLocationAndAddressForSet() {
        locationViewModel.fetchCurrentLocation()
    }
    
    // 지도에서 현재 위치를 표기할 때
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
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.currentLocation = location
                self?.delegate?.centerMapBetweenLocations()
            })
            .store(in: &cancellables)
    }
    
    
    
    func getDistanceBetween() -> Int? {
        guard let currentLocation = currentLocation else {
            print("currentLocation is nil")
            return nil
        }
        guard let destinationLocation = setLocation else {
            print("setLocation is nil")
            return nil
        }
        
        let earthRadius = 6_371_000.0
        
        let currentLat = currentLocation.getLatitude()
        let currentLng = currentLocation.getLongitude()
        let destinationLat = destinationLocation.getLatitude()
        let destinationLng = destinationLocation.getLongitude()
        
        let currentLatRad = currentLat * .pi / 180
        let destinationLatRad = destinationLat * .pi / 180
        let deltaLat = (destinationLat - currentLat) * .pi / 180
        let deltaLng = (destinationLng - currentLng) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(currentLatRad) * cos(destinationLatRad) * sin(deltaLng / 2) * sin(deltaLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = Int(earthRadius * c)
        
        return distance
    }
    
    // 평균 위도, 경도 구하기
    func getAverageLocation() -> Location? {
        guard let currentLocation = currentLocation else {
            print("currentLocation is nil")
            return nil
        }
        guard let destinationLocation = setLocation else {
            print("setLocation is nil")
            return nil
        }
        let averageLatitude = (currentLocation.getLatitude() + destinationLocation.getLatitude()) / 2
        let averageLongitude = (currentLocation.getLongitude() + destinationLocation.getLongitude()) / 2
        let averageLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocation
    }
    
    // 주변 식당을 받아오는 함수
    func fetchNearbyRestaurants() {
        guard let setLocation = setLocation else { return }
        isFetching = true
        searchRestaurantViewModel.fetchNearbyRestaurant(for: setLocation, maximumDistance: maximumDistance)
    }
    // best 식당 5개 정보 가져오기
    func fetchBestRestaurantDetails() {
        guard let bestRestaurantIDs = bestRestaurantIDs else { return }
        searchRestaurantViewModel.fetchBestRestaurantDetails(placeIDs: bestRestaurantIDs)
    }
    // 전체 평균 평점 계산
    func calculateGlobalAverageRating(from restaurants: [PlaceForNearbySearch]) -> Double {
        let totalRating = restaurants
            .compactMap { $0.rating }
            .reduce(0.0, +)
        
        let count = restaurants.filter { $0.rating != nil }.count
        
        return count > 0 ? totalRating / Double(count) : 0.0
    }
    // 인기도 계산 함수
    private func calculatePopularityScore(reviews: Int, rating: Double, totalAverageRating: Double, k: Int) -> Double {
        let reviewsDouble = Double(reviews)
        let kDouble = Double(k)
        
        // 리뷰 수와 조정 상수에 따른 가중치 계산
        let weightForReviews = reviewsDouble / (reviewsDouble + kDouble)
        let weightForAverage = kDouble / (reviewsDouble + kDouble)
        
        // 최종 점수 계산
        let score = (weightForReviews * rating) + (weightForAverage * totalAverageRating)
        return score
    }
}

extension RestaurantMapViewModel: SetAddressWithSearchedResultDelegate {
    func setAddressWithSearchedResult(searchedAddress: String) {
        self.reverseGeocodingViewModel.address = searchedAddress
    }
}
