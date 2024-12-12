//
//  RestaurantDetailServiceImplementaion.swift
//  Data
//
//  Created by 김영훈 on 12/12/24.
//

import Alamofire
import Combine
import Foundation
import Domain

public class RestaurantDetailServiceImplementaion: RestaurantDetailServiceProtocol {
    
    public init() {}
    
    private let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
    private var cancellables = Set<AnyCancellable>()
    
    public func fetchRestaurantDetail(placeId: String) -> AnyPublisher<PlaceDetail, any Error> {
        // API 키 가져오기
        guard let googlePlacesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            print("Failed to get API Key")
            return Fail(error: NSError(domain: "Missing API Key", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let url = baseURL + "place_id=\(placeId)&key=\(googlePlacesAPIKey)"
        
        return Future<PlaceDetail, Error> { promise in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: PlaceDetailSearchResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        promise(.success(response.result))
                    case .failure(let error):
                        print("Failed to fetch restaurant detail: \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

