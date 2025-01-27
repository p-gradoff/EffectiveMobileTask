//
//  NetworkManagerUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 24.01.2025.
//

import XCTest
@testable import EffectiveMobileTask

// MARK: - implement a url-protocol to substitute real network request
class URLProtocolMock: URLProtocol {
    static var mockURLs = [URL?: (error: NetworkError?, data: Data?, response: URLResponse?)]()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url, let (error, data, response) = URLProtocolMock.mockURLs[url] {
            if let specifiedResponse = response {
                self.client?.urlProtocol(self, didReceive: specifiedResponse, cacheStoragePolicy: .notAllowed)
            }
            
            if let specifiedData = data {
                self.client?.urlProtocol(self, didLoad: specifiedData)
            }
            
            if let specifiedError = error {
                self.client?.urlProtocol(self, didFailWithError: specifiedError)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() { }
}

// MARK: - manages all test operations on NetworkManager
final class NetworkManagerUnit: XCTestCase {
    
    // MARK: - do success network session
    func testNetworkSuccessSession() throws {
        
        // MARK: - setup URLSession configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        
        // MARK: - prepare expected test data
        let testRawTask = RawTask(id: 1, todo: "Test task", completed: false, userId: 1)
        let expectedRawTaskList = RawTaskList(todos: [testRawTask], total: 1, skip: 0, limit: 10)
        let mockData = try JSONEncoder().encode(expectedRawTaskList)
        
        // MARK: - prepare network config
        let networkManager = NetworkManager(urlSession: mockSession)
        let url = networkManager.formURL(from: NetworkConfig.baseURLString)!
        let expectation = XCTestExpectation(description: "Success Network request")
        
        // MARK: - prepare mock data
        URLProtocolMock.mockURLs[url] = (
            error: nil,
            data: mockData,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success(let taskList):
                // MARK: - verify taskList info
                XCTAssertEqual(taskList.todos.count, 1)
                XCTAssertEqual(taskList.todos.first?.id, 1)
                XCTAssertEqual(taskList.todos.first?.todo, "Test task")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Request should succeed, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to do network request by wrong URL
    func testNetworkURLError() throws {
        
        // MARK: - prepare network config
        NetworkConfig.baseURLString = ""
        let networkManager = NetworkManager(urlSession: URLSession.shared)
        let expectation = XCTestExpectation(description: "URL Error request")
    
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error, .urlError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to get response with server error
    func testNetworkServerError() throws {
        
        // MARK: - prepare URL Session configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        
        // MARK: - prepare network config
        let networkManager = NetworkManager(urlSession: mockSession)
        let url = networkManager.formURL(from: NetworkConfig.baseURLString)!
        let expectation = XCTestExpectation(description: "Server Error request")
        
        // MARK: - prepare mock data
        URLProtocolMock.mockURLs[url] = (
            error: .serverError,
            data: nil,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error, .serverError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to get response with status code 500
    func testNetworkResponseError() throws {
        
        // MARK: - prepare URL Session configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        
        // MARK: - prepare network config
        let networkManager = NetworkManager(urlSession: mockSession)
        let url = networkManager.formURL(from: NetworkConfig.baseURLString)!
        let expectation = XCTestExpectation(description: "URLResponse Error request")
        
        // MARK: - prepare mock data
        URLProtocolMock.mockURLs[url] = (
            error: nil,
            data: nil,
            response: HTTPURLResponse(url: url, statusCode: 300, httpVersion: nil, headerFields: nil)
        )
        
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to get empty data response
    func testNetworkDataError() throws {
        
        // MARK: - prepare URL Session configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        
        // MARK: - prepare network config
        let networkManager = NetworkManager(urlSession: mockSession)
        let url = networkManager.formURL(from: NetworkConfig.baseURLString)!
        let expectation = XCTestExpectation(description: "Data Error request")
        
        // MARK: - prepare mock data
        URLProtocolMock.mockURLs[url] = (
            error: nil,
            data: nil,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error, .dataError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to parse data with incorrect data
    func testNetworkParsingError() throws {
        
        // MARK: - prepare URL Session configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        
        // MARK: - prepare network config
        let networkManager = NetworkManager(urlSession: mockSession)
        let url = networkManager.formURL(from: NetworkConfig.baseURLString)!
        let expectation = XCTestExpectation(description: "Parsing Error request")
        
        // MARK: - prepare mock data
        let testData = try JSONEncoder().encode("Test Data")
        URLProtocolMock.mockURLs[url] = (
            error: nil,
            data: testData,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        
        // MARK: - do request
        networkManager.doRequest { result in
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertEqual(error, .parsingError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
