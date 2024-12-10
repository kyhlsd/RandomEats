import Alamofire
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
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String] {
        // API 키 가져오기
        guard let googlePlacesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            print("Failed to get API Key")
            return []
        }
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        var allPlaceNames = [String]()
        var nextPageToken: String? = nil
        
        repeat {
            var parameters: [String: String] = [
                "location": "\(latitude),\(longitude)",
                "radius": "\(maximumDistance)",
                "type": "restaurant",
                "key": googlePlacesAPIKey
            ]
            
            if let token = nextPageToken {
                parameters["pageToken"] = token
            }
            
            // API 호출
            let response: PlacesSearchResponse = try await withCheckedThrowingContinuation { continuation in
                AF.request(url, method: .get, parameters: parameters)
                    .validate()
                    .responseDecodable(of: PlacesSearchResponse.self) { result in
                        switch result.result {
                        case .success(let placesSearchResponse):
                            continuation.resume(returning: placesSearchResponse)
                        case .failure(let error):
                            print("Error: \(error)")
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            // 응답 처리
            for place in response.results {
                allPlaceNames.append(place.name)
            }
            
            // 다음 페이지 토큰 갱신
            nextPageToken = response.next_page_token
            
            // nextPageToken이 바로 사용 불가능할 수 있으므로 약간의 지연 추가 (권장 사항)
            if nextPageToken != nil {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2초 대기
            }
            
        } while nextPageToken != nil
        
        return allPlaceNames
        
    }
}

