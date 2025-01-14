//
//  CustomAnnotation.swift
//  Domain
//
//  Created by 김영훈 on 1/8/25.
//

import MapKit

public class DirectionPlaceAnnotation: MKPointAnnotation {
    public let type: DirectionPlaceAnnotationType
    
    public init(type: DirectionPlaceAnnotationType) {
        self.type = type
    }
}

public enum DirectionPlaceAnnotationType {
    case origin
    case destination
}

public class BestRestaurantAnnotation: MKPointAnnotation {
    public var type: BestRestaurantAnnotationType
    
    public init(type: BestRestaurantAnnotationType) {
        self.type = type
    }
}

public enum BestRestaurantAnnotationType {
    case selected
    case nonSelected
}
