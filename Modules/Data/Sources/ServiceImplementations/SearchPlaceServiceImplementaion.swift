//
//  SearchPlaceServiceImplementaion.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Foundation
import Combine
import Domain
import Alamofire

public class SearchPlaceServiceImplementaion: SearchPlaceServiceProtocol {
    
    public init() {}
    
    private let baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    private var cancellables = Set<AnyCancellable>()
    
    public func fetchPlacePrediction(query: String) -> AnyPublisher<[PlacePrediction], any Error> {
        
        guard let googlePlacesAPIKey = getAPIKey() else {
            return Fail(error: NSError(domain: "Missing API Key", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let url = baseURL + "input=\(query)&key=\(googlePlacesAPIKey)&language=ko"
        
        return Future<[PlacePrediction], Error> { promise in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: PlacesAutoCompleteResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        promise(.success(response.predictions))
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

}
