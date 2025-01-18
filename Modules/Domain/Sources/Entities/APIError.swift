//
//  Error.swift
//  Data
//
//  Created by 김영훈 on 1/19/25.
//

import Foundation

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
