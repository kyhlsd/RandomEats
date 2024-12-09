//
//  LocationServiceImpletation.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import CoreLocation
import Domain

public class LocationServiceImplementation: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<Location, Error>?
    
    public override init() {
        super.init()
        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization()
    }
    
    public func fetchCurrentLocation() async throws -> Location {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationManager.requestWhenInUseAuthorization()
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
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 오류가 발생하면 continuation을 통해 오류를 반환
        continuation?.resume(throwing: error)
        // 위치 업데이트가 실패했을 경우 더 이상 위치 업데이트를 받지 않도록 중지
        locationManager.stopUpdatingLocation()
    }
}
