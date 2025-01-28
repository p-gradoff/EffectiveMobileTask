//
//  TaskListInteractorFailedUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 28.01.2025.
//

import XCTest
import CoreData
@testable import EffectiveMobileTask

// MARK: - mock store manager child that returns errors
final class MockStoreManagerFailure: StoreManager {
    override func createTask(taskDescription: NSEntityDescription?, with id: Int, creationDate: String, content: String, completionStatus: Bool, completion: @escaping ((Result<Void, EffectiveMobileTask.CoreDataError>) -> Void)) {
        
        completion(.failure(.creationError))
    }
    
    override func fetchTaskList(completion: @escaping ((Result<[Task], CoreDataError>) -> Void)) {
        completion(.failure(.fetchError))
    }
    
    override func updateTask(with change: TaskChange, by id: Int, completion: @escaping ((Result<Task, CoreDataError>) -> Void)) {
        completion(.failure(.updateError))
    }
    
    override func removeTask(by id: Int, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        completion(.failure(.removeError))
    }
}

// MARK: - manages mock network manager's funcs
final class MockNetworkManagerFailure: NetworkManager {
    override func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void) {
        completion(.failure(.serverError))
    }
}

// MARK: - manages all test functions
final class TaskListInteractorFailedUnit: XCTestCase {
    var sut: TaskListInteractor!
    var mockStoreManager: StoreManager!
    
    // MARK: - setup TaskListInteractorFailedUnit
    override func setUp() {
        super.setUp()
        
        // MARK: - setup network manager's config
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        let mockNetworkManager = MockNetworkManagerFailure(urlSession: mockSession)
        
        // MARK: - setup test contexts to StoreManager
        let coreDataStack = CoreDataStack.shared
        mockStoreManager = MockStoreManagerFailure(
            backgroundContext: coreDataStack.mainContext,
            mainContext: coreDataStack.mainContext
        )
        
        sut = TaskListInteractor(networkManager: mockNetworkManager, storeManager: mockStoreManager)
    }

    // MARK: - try to save empty tasks list
    func testSaveLoadedTaskList_EmptyList() {
        let expectation = XCTestExpectation(description: "Empty List Handling")
        
        // MARK: - try to save loaded tasks list
        sut.saveLoadedTaskList([]) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Empty list should save successfully")
            case .failure(let error):
                XCTFail("Empty list saving failed, got error \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to save partial wrong data
    func testSaveLoadedTaskList_PartialFailure() {
        let expectation = XCTestExpectation(description: "Partial Save Failure")
        
        // MARK: - prepare mock data
        let taskList = [
            RawTask(id: 1, todo: "Valid Task", completed: false, userId: 1),
            RawTask(id: -1, todo: "", completed: false, userId: -1)
        ]
        
        // MARK: - try to save loaded tasks list
        sut.saveLoadedTaskList(taskList) { result in
            switch result {
            case .success:
                XCTFail("Partial invalid data should fail")
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: -  try to save loaded large invalid tasks list
    func testSaveLoadedTaskList_LargeInvalidList() {
        let expectation = XCTestExpectation(description: "Large List Failure")
        
        // MARK: - prepare large mock data
        let taskList = (0..<100).map { index in
            RawTask(
                id: index % 2 == 0 ? index : -1,
                todo: index % 2 == 0 ? "Valid Task" : "",
                completed: false,
                userId: index
            )
        }
        
        // MARK: - try to save loaded tasks list
        sut.saveLoadedTaskList(taskList) { result in
            switch result {
            case .success:
                XCTFail("List with invalid tasks should fail")
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - try to load task list
    func testLoadTasksListFromStorage_FetchError() throws {
        let expectation = XCTestExpectation(description: "Load Tasks Lists Fetch Error")
        
        // MARK: - try to save loaded tasks list
        sut.loadTasksListFromStorage { result in
            switch result {
            case .success:
                XCTFail("Load tasks tist should fail")
            case .failure(let error):
                XCTAssertEqual(error, .fetchError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to download raw task list from internet
    func testDownloadRawTasksList_NetworkError() throws {
        let expectation = XCTestExpectation(description: "Download Raw Tasks List Failure")
        
        // MARK: - try to download raw tasks list
        sut.downloadRawTasksList { result in
            switch result {
            case .success:
                XCTFail("Download raw tasks list should fail")
            case .failure(let error):
                XCTAssertEqual(error, .serverError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try change task
    func testUpdateTaskCompletionStatus_UpdateError() throws {
        let expectation = XCTestExpectation(description: "Update Task Completion Status Failure")
        
        // MARK: - prepare mock data
        let mockID = 1
        
        // MARK: - try to update completion status
        sut.updateTaskCompletionStatus(by: mockID) { result in
            switch result {
            case .success:
                XCTFail("Updating task completion status should fail")
            case .failure(let error):
                XCTAssertEqual(error, .updateError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to remove task
    func testRemoveTaskByID_RemoveError() throws {
        let expectation = XCTestExpectation(description: "Remove Task Failure")
        
        // MARK: - prepare mock data
        let mockID = 1
        
        // MARK: - try to remove task
        sut.removeTask(by: mockID) { result in
            switch result {
            case .success:
                XCTFail("Removing task should fail")
            case .failure(let error):
                XCTAssertEqual(error, .removeError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

