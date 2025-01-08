//
//  DirectionViewModel.swift
//  Data
//
//  Created by 김영훈 on 1/8/25.
//

import Foundation
import Domain

public class DirectionViewModel {
    let originLocation: Location
    let destinationLocation: Location
    
    init(originLocation: Location, destinationLocation: Location) {
        self.originLocation = originLocation
        self.destinationLocation = destinationLocation
    }
    
    // 평균 위도, 경도 구하기
    func getAverageLocation() -> Location {
        let averageLatitude = (originLocation.getLatitude() + destinationLocation.getLatitude()) / 2
        let averageLongitude = (originLocation.getLongitude() + destinationLocation.getLongitude()) / 2
        let averageLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocation
    }
    
    // 두 지점 사이 거리 구하기
    func getDistanceBetween() -> Int {
        
        let earthRadius = 6_371_000.0
        
        let currentLat = originLocation.getLatitude()
        let currentLng = originLocation.getLongitude()
        let destinationLat = destinationLocation.getLatitude()
        let destinationLng = destinationLocation.getLongitude()
        
        let currentLatRad = currentLat * .pi / 180
        let destinationLatRad = destinationLat * .pi / 180
        let deltaLat = (destinationLat - currentLat) * .pi / 180
        let deltaLng = (destinationLng - currentLng) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(currentLatRad) * cos(destinationLatRad) * sin(deltaLng / 2) * sin(deltaLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = Int(earthRadius * c)
        
        return distance
    }
}
