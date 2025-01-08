//
//  CustomAnnotation.swift
//  Domain
//
//  Created by 김영훈 on 1/8/25.
//

import MapKit

public class CustomPlaceAnnotation: MKPointAnnotation {
    public let type: AnnotationType
    
    public init(type: AnnotationType) {
        self.type = type
    }
}

public enum AnnotationType {
    case origin
    case destination
}
