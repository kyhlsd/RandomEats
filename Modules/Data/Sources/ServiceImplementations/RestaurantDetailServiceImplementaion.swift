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
        
        guard let googlePlacesAPIKey = getAPIKey() else {
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
    
    // API 키 가져오기
    private func getAPIKey() -> String? {
        guard let googlePlacesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            print("Missing API Key")
            return nil
        }
        return googlePlacesAPIKey
    }
    
    // Photo API URL 생성
    private func constructPhotoURL(photoReference: String) -> URL? {
        guard let googlePlacesAPIKey = getAPIKey() else {
            return nil
        }
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/photo")
        components?.queryItems = [
            URLQueryItem(name: "maxwidth", value: "400"),
            URLQueryItem(name: "photo_reference", value: photoReference),
            URLQueryItem(name: "key", value: googlePlacesAPIKey),
        ]
        return components?.url
    }
    
    public func fetchPhotoURL(photoReference: String) -> AnyPublisher<URL, Error> {
        
        guard let url = constructPhotoURL(photoReference: photoReference) else {
            print("Failed to get URL from photo reference")
            return Fail(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        return Future<URL, Error> { promise in
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        promise(.success(url))
                    case .failure(let error):
                        print("Failed to fetch photo URL: \(error)")
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

}

