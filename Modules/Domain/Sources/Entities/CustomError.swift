//
//  Error.swift
//  Data
//
//  Created by 김영훈 on 1/19/25.
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
            return "알 수 없는 에러로 위치 정보를 가져오는데 실패했습니다."
        }
    }
}

public enum APIError: Error {
    case noInternetConnection
    case serverError
    case invalidResponse
    case unknownError(description: String)
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "인터넷이 연결되지 않았습니다. 인터넷 연결을 확인해주세요."
        case .serverError:
            return "서버 문제가 발생했습니다. 다시 시도해주세요."
        case .invalidResponse:
            return "잘못된 응답이 발생했습니다. 다시 시도해주세요."
        case .unknownError(let description):
            return "알 수 없는 에러가 발생했습니다.\n\(description)"
        }
    }
}

public enum CoreDataError: Error {
    case saveFailed
    case fetchFailed
    case unknown(description: String)
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "데이터 저장에 실패했습니다."
        case .fetchFailed:
            return "데이터 불러오기에 실패했습니다."
        case .unknown(let description):
            return "알 수 없는 데이터 에러가 발생했습니다.\n\(description)"
        }
    }
}
