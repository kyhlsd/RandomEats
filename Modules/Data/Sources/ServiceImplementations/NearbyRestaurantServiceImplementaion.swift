//
//  NearbyRestaurantServiceImplementaion.swift
//  Data
//
//  Created by 김영훈 on 12/10/24.
//

import Alamofire
import Combine
import Foundation
import Domain

public class NearbyRestaurantServiceImplementaion: NearbyRestaurantServiceProtocol {
    
    public init() {}
    
    private let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    private var cancellables = Set<AnyCancellable>()
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) -> AnyPublisher<[PlaceForNearbySearch], Error> {
        // API 키 가져오기
        guard let googlePlacesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            print("Failed to get API Key")
            return Fail(error: NSError(domain: "Missing API Key", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let initialParameters: [String: String] = [
            "location": "\(latitude),\(longitude)",
            "radius": "\(maximumDistance)",
            "type": "restaurant",
            "key": googlePlacesAPIKey
        ]
        
        // 첫 페이지 요청 Publisher
        return fetchPage(parameters: initialParameters)
            .flatMap { response -> AnyPublisher<[PlaceForNearbySearch], Error> in
                self.fetchAllPages(initialResults: response.results, nextPageToken: response.next_page_token, apiKey: googlePlacesAPIKey, longitude: longitude, latitude: latitude, maximumDistance: maximumDistance)
            }
            .eraseToAnyPublisher()
    }
        
    private func fetchPage(parameters: [String: String]) -> AnyPublisher<PlacesNearbySearchResponse, Error> {
        return Future<PlacesNearbySearchResponse, Error> { promise in
            AF.request(self.url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: PlacesNearbySearchResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        if let urlError = error.asAFError?.underlyingError as? URLError,
                           urlError.code == .notConnectedToInternet {
                            promise(.failure(APIError.noInternetConnection))
                        } else {
                            promise(.failure(APIError.unknownError(description: error.localizedDescription)))
                        }
                    }
                }
        }
        .eraseToAnyPublisher()
    }
        
    private func fetchAllPages(initialResults: [PlaceForNearbySearch], nextPageToken: String?, apiKey: String, longitude: Double, latitude: Double, maximumDistance: Int) -> AnyPublisher<[PlaceForNearbySearch], Error> {
        guard let token = nextPageToken else {
            return Just(initialResults)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let parameters: [String: String] = [
            "location": "\(latitude),\(longitude)",
            "radius": "\(maximumDistance)",
            "pagetoken": token,
            "key": apiKey
        ]
        return Just(())
            // Google Places API 2초 딜레이
            .delay(for: .seconds(2), scheduler: DispatchQueue.global())
            .flatMap { _ in
                return self.fetchPage(parameters: parameters)
            }
            .flatMap { response -> AnyPublisher<[PlaceForNearbySearch], Error> in
                let combinedResults = initialResults + response.results
                return self.fetchAllPages(initialResults: combinedResults, nextPageToken: response.next_page_token, apiKey: apiKey, longitude: longitude, latitude: latitude, maximumDistance: maximumDistance)
            }
            .eraseToAnyPublisher()
    }
    
}

