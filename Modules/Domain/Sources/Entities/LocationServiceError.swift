//
//  LocationServiceError.swift
//  Data
//
//  Created by 김영훈 on 12/26/24.
//

import Foundation

public enum LocationServiceError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "위치 서비스 권한이 거부되었습니다. 설정 앱에서 권한을 확인해주세요."
        case .permissionRestricted:
            return "위치 서비스 사용이 제한되었습니다. 관리자에게 문의해주세요."
        case .unknownError:
            return "위치 정보를 가져오는데 실패했습니다."
        }
    }
}
