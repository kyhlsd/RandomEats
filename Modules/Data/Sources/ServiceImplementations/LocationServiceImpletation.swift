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

public class LocationServiceImplementation: NSObject, LocationServiceProtocol {
    
    private let locationManager = CLLocationManager()
    private var didUpdateLocationsClosure: ((Location) -> Void)?
    private var didFailWithErrorClosure: ((Error) -> Void)?
    
    private var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        self.locationManager.delegate = self
    }
    
    public func fetchCurrentLocation() -> AnyPublisher<Location, Error> {
        return Future { promise in
            self.locationManager.requestWhenInUseAuthorization()
            let status = self.locationManager.authorizationStatus
            if status == .denied {
                promise(.failure(LocationServiceError.permissionDenied))
                return
            } else if status == .restricted {
                promise(.failure(LocationServiceError.permissionRestricted))
                return
            }
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            // 위치 업데이트 클로저 설정
            self.didUpdateLocationsClosure = { location in
                print("closureSuccess")
                promise(.success(location))  // 위치가 업데이트되면 성공적으로 값을 반환
            }
            
            // 실패 클로저 설정
            self.didFailWithErrorClosure = { error in
                print("closureFailure")
                promise(.failure(error))  // 오류가 발생하면 실패를 반환
            }
        }
        .eraseToAnyPublisher()
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

extension LocationServiceImplementation: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let locationModel = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            // 위치 업데이트 시, 클로저 호출
            didUpdateLocationsClosure?(locationModel)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        didFailWithErrorClosure?(error)
    }
}
