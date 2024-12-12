import Alamofire
import Combine
import Foundation

// Google Places API 응답 모델 정의
struct PlacesSearchResponse: Decodable {
    let results: [Place]
    let next_page_token: String?
}

struct Place: Decodable {
    let name: String
}

public class NearbyRestaurantServiceImplementaion: NearbyRestaurantServiceProtocol {
    
    public init() {}
    
    private let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    private var cancellables = Set<AnyCancellable>()
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) -> AnyPublisher<[String], Error> {
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
            .flatMap { response -> AnyPublisher<[String], Error> in
                self.fetchAllPages(initialResults: response.results.map { $0.name }, nextPageToken: response.next_page_token, apiKey: googlePlacesAPIKey, longitude: longitude, latitude: latitude, maximumDistance: maximumDistance)
            }
            .eraseToAnyPublisher()
    }
        
    private func fetchPage(parameters: [String: String]) -> AnyPublisher<PlacesSearchResponse, Error> {
        return Future<PlacesSearchResponse, Error> { promise in
            AF.request(self.url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: PlacesSearchResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        print("response: \(response)")
                        promise(.success(response))
                    case .failure(let error):
                        print("Error: \(error)")
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
        
    private func fetchAllPages(initialResults: [String], nextPageToken: String?, apiKey: String, longitude: Double, latitude: Double, maximumDistance: Int) -> AnyPublisher<[String], Error> {
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
        
        return fetchPage(parameters: parameters)
            .delay(for: .seconds(2), scheduler: DispatchQueue.global())
            .flatMap { response -> AnyPublisher<[String], Error> in
                let combinedResults = initialResults + response.results.map { $0.name }
                print("Fetched \(response.results.count) results, Total: \(combinedResults.count)")
                return self.fetchAllPages(initialResults: combinedResults, nextPageToken: response.next_page_token, apiKey: apiKey, longitude: longitude, latitude: latitude, maximumDistance: maximumDistance)
            }
            .eraseToAnyPublisher()
    }
}

