//
//  ReverseGeocodingServiceImplementaion.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation
import Combine
import Alamofire
import Domain
import Shared
import CoreData

public class ReverseGeocodingServiceImplementaion: ReverseGeocodingServiceProtocol {
    
    private var context: NSManagedObjectContext
    
    private let baseURL = "https://maps.googleapis.com/maps/api/geocode/json?"
    private var cancellables = Set<AnyCancellable>()
    
    public init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    public func fetchAddress(latitude: Double, longitude: Double) -> AnyPublisher<String, any Error> {
        
        guard let googlePlacesAPIKey = getAPIKey() else {
            return Fail(error: NSError(domain: "Missing API Key", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        let url = "\(baseURL)latlng=\(latitude),\(longitude)&key=\(googlePlacesAPIKey)"
        
        return Future<String, Error> { promise in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: ReverseGeocodingResponse.self) { result in
                    switch result.result {
                    case .success(let response):
                        if let address = response.results.first?.formattedAddress {
                            promise(.success(address))
                        } else {
                            promise(.failure(NSError(domain: "No address found", code: 1, userInfo: nil)))
                        }
                    case .failure(let error):
                        print("Failed to fetch address: \(error.localizedDescription)")
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
    
    public func fetchPreviousAddress() -> AnyPublisher<String, Error> {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        
        return Future { promise in
            do {
                let entities = try self.context.fetch(fetchRequest)
                // 기본값 서울시청
                let address = entities.map {
                    $0.address ?? "서울 시청"
                }.first ?? "서울 시청"
                promise(.success(address))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateCoreDataAddress(address: String) {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            if let addressEntity = results.first {
                addressEntity.address = address
            } else {
                let newAddressEntity = AddressEntity(context: context)
                newAddressEntity.address = address
            }
            try context.save()
        } catch {
            print("Failed to update address: \(error)")
        }
    }
}
