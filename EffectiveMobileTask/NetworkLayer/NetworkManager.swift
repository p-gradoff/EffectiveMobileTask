//
//  NetworkManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

// MARK: - output funcs
protocol NetworkManagerOutput: AnyObject {
    func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void)
}

// MARK: - network errors
enum NetworkError: Error {
    case urlError
    case responseError
    case serverError
    case dataError
    case parsingError
}

// MARK: - possible network errors
extension NetworkError {
    var message: String {
        switch self {
        case .urlError: return "Unexpected Error while URL forming"
        case .responseError: return "Response error description"
        case .serverError: return "Server error description"
        case .dataError: return "Data error description"
        case .parsingError: return "Parsing error description"
        }
    }
}

// MARK: - network request config
struct NetworkConfig {
    static var baseURLString: String = "https://dummyjson.com/todos"
    static var httpMethod: String = "GET"
    static var valueType: String = "application/json"
    static var contentType: String = "Content-Type"
}

final class NetworkManager: NetworkManagerOutput {
    // MARK: - private properties
    private let urlSession: URLSession
    
    // MARK: - initialization
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func formURL(from urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    // MARK: - form request
    func formRequest(by url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = NetworkConfig.httpMethod
        request.setValue(NetworkConfig.valueType, forHTTPHeaderField: NetworkConfig.contentType)
        return request
    }
    
    // MARK: - do request
    func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void) {
        guard let url = formURL(from: NetworkConfig.baseURLString) else {
            completion(.failure(.urlError))
            return
        }
        let request = formRequest(by: url)
        
        urlSession.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.isSuccess() else {
                completion(.failure(.responseError))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                completion(.failure(.dataError))
                return
            }
            
            do {
                let rawData = try JSONDecoder().decode(RawTaskList.self, from: data)
                completion(.success(rawData))
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
}
