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
    private var cancellables = Set<AnyCancellable>()
    private var authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Error>()
    
    public init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        self.locationManager.delegate = self
    }
    
    public func fetchCurrentLocation() -> AnyPublisher<Location, Error> {
        return requestAuthorization()
            .flatMap { [weak self] status -> AnyPublisher<Location, Error> in
                guard let self = self else {
                    return Fail(error: LocationServiceError.unknownError).eraseToAnyPublisher()
                }
                
                switch status {
                case .denied:
                    return Fail(error: LocationServiceError.permissionDenied).eraseToAnyPublisher()
                case .restricted:
                    return Fail(error: LocationServiceError.permissionRestricted).eraseToAnyPublisher()
                case .authorizedAlways, .authorizedWhenInUse:
                    return self.startUpdatingLocation()
                default:
                    return Fail(error: LocationServiceError.unknownError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func requestAuthorization() -> AnyPublisher<CLAuthorizationStatus, Error> {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
            return authorizationSubject.eraseToAnyPublisher()
        } else {
            return Just(status)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    private func startUpdatingLocation() -> AnyPublisher<Location, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            self.didUpdateLocationsClosure = { location in
                self.locationManager.stopUpdatingLocation()
                promise(.success(location))
            }
            
            self.didFailWithErrorClosure = { error in
                self.locationManager.stopUpdatingLocation()
                promise(.failure(error))
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
                // TODO: coredata error 처리
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
            // TODO: coredata 에러 처리
            print("Failed to update location: \(error)")
        }
    }
}

extension LocationServiceImplementation: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationSubject.send(manager.authorizationStatus)
        authorizationSubject.send(completion: .finished)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let locationModel = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            // 위치 업데이트 시, 클로저 호출
            didUpdateLocationsClosure?(locationModel)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithErrorClosure?(error)
    }
}

