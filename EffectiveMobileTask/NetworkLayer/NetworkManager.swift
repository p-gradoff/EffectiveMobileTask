//
//  NetworkManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

protocol NetworkOutput: AnyObject {
    func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void)
}

// MARK: - network errors
enum NetworkError: Error {
    case networkError
    case responseError
    case serverError
    case dataError
    case parsingError
}

extension NetworkError {
    var message: String {
        switch self {
        case .networkError: return "Network error description"
        case .responseError: return "Response error description"
        case .serverError: return "Server error description"
        case .dataError: return "Data error description"
        case .parsingError: return "Parsing error description"
        }
    }
}

final class NetworkManager: NetworkOutput {
    // MARK: - based url
    private let baseURL: URL = URL(string: "https://dummyjson.com/todos")!
    
    // MARK: - form request
    private func formRequest() -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // MARK: - do request
    func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void) {
        let request = formRequest()
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(NetworkError.serverError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.isSuccess() else {
                completion(.failure(NetworkError.responseError))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.dataError))
                return
            }
            
            do {
                let rawData = try JSONDecoder().decode(RawTaskList.self, from: data)
                completion(.success(rawData))
            } catch {
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }
}
