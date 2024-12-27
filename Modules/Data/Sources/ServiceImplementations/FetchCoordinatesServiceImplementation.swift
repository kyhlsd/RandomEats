//
//  FetchCoordinatesServiceImplementation.swift
//  Data
//
//  Created by 김영훈 on 12/27/24.
//

import Foundation
import Combine
import Domain
import Alamofire

public class FetchCoordinatesServiceImplementaion: FetchCoordinatesServiceProtocol {
    
    public init() {}
    
    private let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
    private var cancellables = Set<AnyCancellable>()
    
    public func fetchCoordinates(placeId: String) -> AnyPublisher<Location, any Error> {
        
        guard let googlePlacesAPIKey = getAPIKey() else {
            return Fail(error: NSError(domain: "Missing API Key", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let url = baseURL + "place_id=\(placeId)&fields=geometry&key=\(googlePlacesAPIKey)"
        
        return Future<Location, any Error> { promise in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: PlaceCoordinatesResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        if let lat = response.result.geometry.location.lat,
                           let lng = response.result.geometry.location.lng {
                            let location = Location(latitude: lat, longitude: lng)
                            promise(.success(location))
                        } else {
                            let error = NSError(domain: "PlaceCoordinatesError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location data not found"])
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        print("Failed to fetch place coordinates: \(error.localizedDescription)")
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

