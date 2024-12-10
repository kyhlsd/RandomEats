import Alamofire
import Foundation

// Google Places API 응답 모델 정의
struct PlacesSearchResponse: Decodable {
    let places: [Place]
}

struct Place: Decodable {
    let displayName: DisplayName
}

struct DisplayName: Decodable {
    let text: String
    let languageCode: String
}

public class NearbyRestaurantServiceImplementaion: NearbyRestaurantServiceProtocol {
    
    public init() {}
    
    public func fetchNearbyRestaurant(latitude: Double, longitude: Double, maximumDistance: Int) async throws -> [String] {
        // API 키 가져오기
        guard let googlePlacesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            print("Failed to get API Key")
            return []
        }
        
        let url = "https://places.googleapis.com/v1/places:searchNearby"
        let parameters: [String: Any] = [
            "includedTypes": ["restaurant"],
            "maxResultCount": 1,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": maximumDistance
                ]
            ]
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": googlePlacesAPIKey,
            "X-Goog-FieldMask": "places.displayName"
        ]
        
        // POST 요청 보내기
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()  // 응답 상태 코드 검증
            .responseDecodable(of: PlacesSearchResponse.self) { response in
                switch response.result {
                case .success(let placesSearchResponse):
                    // 성공적인 응답 처리
                    for place in placesSearchResponse.places {
                        // displayName.text 값 출력
                        print("Place displayName: \(place.displayName.text)")
                    }
                    
                case .failure(let error):
                    // 실패한 경우 오류 처리
                    print("Error: \(error)")
                }
            }
        return []
    }
}

