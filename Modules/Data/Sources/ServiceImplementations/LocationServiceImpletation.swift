//
//  LocationServiceImpletation.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import CoreLocation
import Domain
import Shared
import CoreData
import Combine

public class LocationServiceImplementation: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Location, Error>?
    
    private var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        self.locationManager.delegate = self
    }
    
    public func fetchCurrentLocation() async throws -> Location {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationManager.requestWhenInUseAuthorization()
            let status = locationManager.authorizationStatus
            if status == .denied {
                continuation.resume(throwing: LocationServiceError.permissionDenied)
                return
            } else if status == .restricted {
                continuation.resume(throwing: LocationServiceError.permissionRestricted)
                return
            }
            
            self.continuation = continuation
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate 메서드 구현
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let locationModel = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            // 위치 업데이트 시, continuation을 통해 값을 반환
            continuation?.resume(returning: locationModel)
            // 위치 업데이트가 완료되면 더 이상 위치 업데이트를 받지 않도록 중지
            locationManager.stopUpdatingLocation()
            continuation = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 중복 호출 방지
        guard let continuation = continuation else { return }
        self.continuation = nil // 사용 후 nil로 처리
        
        // 오류가 발생하면 continuation을 통해 오류를 반환
        continuation.resume(throwing: error)
        // 위치 업데이트가 실패했을 경우 더 이상 위치 업데이트를 받지 않도록 중지
        locationManager.stopUpdatingLocation()
    }
    
    public func fetchPreviousLocation() -> AnyPublisher<Location, Error> {
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        
        return Future { promise in
            do {
                let entities = try self.context.fetch(fetchRequest)
                // 기본값 서울시청
                let location = entities.map {
                    Location(latitude: $0.latitude, longitude: $0.longitude)
                }.first ?? Location(latitude: 37.5663, longitude: 126.9779)
                promise(.success(location))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateCoreDataLocation(location: Location) {
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            if let locationEntity = results.first {
                locationEntity.latitude = location.getLatitude()
                locationEntity.longitude = location.getLongitude()
            } else {
                let newLocationEntity = LocationEntity(context: context)
                newLocationEntity.latitude = location.getLatitude()
                newLocationEntity.longitude = location.getLongitude()
            }
            try context.save()
        } catch {
            print("Failed to update location: \(error)")
        }
    }
}
