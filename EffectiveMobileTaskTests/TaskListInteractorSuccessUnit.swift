//
//  TaskListInteractorUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 27.01.2025.
//

import XCTest
import CoreData
@testable import EffectiveMobileTask

// MARK: - manages mock network manager's funcs
final class MockNetworkManagerSuccess: NetworkManager {
    override func doRequest(_ completion: @escaping (Result<RawTaskList, NetworkError>) -> Void) {
        let mockRawTaskList = RawTaskList(
            todos: [RawTask.getRawTask()],
            total: 1, skip: 0, limit: 1
        )
        completion(.success(mockRawTaskList))
    }
}

// MARK: - manages all test
final class TaskListInteractorSuccessUnit: XCTestCase {
    var sut: TaskListInteractor!
    var mockStoreManager: StoreManager!

    // MARK: - setup TaskListInteractorSuccessUnit
    override func setUp() {
        super.setUp()
        
        // MARK: - setup network manager's config
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        let mockNetworkManager = MockNetworkManagerSuccess(urlSession: mockSession)
        
        // MARK: - setup test contexts to StoreManager
        let coreDataStack = CoreDataStack.shared
        mockStoreManager = StoreManager(
            backgroundContext: coreDataStack.mainContext,
            mainContext: coreDataStack.mainContext
        )
        
        sut = TaskListInteractor(networkManager: mockNetworkManager, storeManager: mockStoreManager)
    }

    // MARK: - save loaded tasks list and verify it
    func testSaveLoadedTaskList_Success() throws {
        let expectation = XCTestExpectation(description: "Save Loaded Task List Success")
        
        // MARK: - prepare mock task list
        let mockRawTask = RawTask.getRawTask()
        let mockRawTaskList = [mockRawTask]
        
        // MARK: - save task and checkout
        sut.saveLoadedTaskList(mockRawTaskList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // MARK: - fetch created task and verify it
                mockStoreManager.fetchTask(by: mockRawTask.id) { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success(let task):
                        XCTAssertEqual(mockRawTask.id, task.id)
                        XCTAssertEqual(mockRawTask.todo, task.content)
                        XCTAssertEqual(mockRawTask.completed, task.completionStatus)
                    case .failure(let error):
                        XCTFail("Task not found, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    mockStoreManager.removeTask(by: mockRawTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            break
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                    
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Task should be saved, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to save large amount of tasks
    func testSaveLoadedTaskList_BigAmount() throws {
        let expectation = XCTestExpectation(description: "Save Loaded Task List Success")
        
        // MARK: - prepare big task list
        var mockRawTaskList: [RawTask] = []
        
        let total = 100
        for counter in 0..<total {
            var rawTask = RawTask.getRawTask()
            rawTask.id = counter
            rawTask.userId = counter
            
            mockRawTaskList.append(rawTask)
        }
        
        // MARK: - save task and checkout
        sut.saveLoadedTaskList(mockRawTaskList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // MARK: - fetch created task and verify it
                mockStoreManager.fetchTaskList { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success(let taskList):
                        XCTAssertEqual(taskList.count, total)
                    case .failure(let error):
                        XCTFail("Task not found, got error \(error)")
                    }
                    
                    // MARK: - remove task list
                    mockStoreManager.removeAllTasks { deleteResult in
                        switch deleteResult {
                        case .success:
                            XCTAssert(true, "Deletion successfully done")
                        case .failure(let error):
                            XCTFail("Deletion failed, got error \(error)")
                        }
                    }
                    
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Task should be saved, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - try to load tasks list from storage
    func testLoadTasksListFromStorage_Success() throws {
        let expectation = XCTestExpectation(description: "Load Tasks List From Storage Success")
        
        // MARK: - prepare task
        let mockRawTask = RawTask.getRawTask()
        let mockRawTaskList = [mockRawTask]
        
        // MARK: - save task and checkout
        sut.saveLoadedTaskList(mockRawTaskList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // MARK: - load tasks list from storage
                sut.loadTasksListFromStorage { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let tasksList):
                        XCTAssertEqual(tasksList.count, 1)
                    case .failure(let error):
                        XCTFail("Tasks list should be loaded, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    mockStoreManager.removeTask(by: mockRawTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            break
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                    
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Task should be saved, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - check data after download
    func testDownloadRawTasksList_Success() throws {
        let expectation = XCTestExpectation(description: "Download Raw Tasks List")
        
        // MARK: - prepare mock raw tasks list
        let mockRawTask = RawTask.getRawTask()
        let mockTotal = 1
        let mockSkip = 0
        let mockLimit = 1
        
        // MARK: - download raw tasks list
        sut.downloadRawTasksList { result in
            switch result {
            case .success(let rawTasksList):
                XCTAssertEqual(rawTasksList.skip, mockSkip)
                XCTAssertEqual(rawTasksList.total, mockTotal)
                XCTAssertEqual(rawTasksList.limit, mockLimit)
                XCTAssertEqual(rawTasksList.todos.first?.todo, mockRawTask.todo)
                XCTAssertEqual(rawTasksList.todos.first?.id, mockRawTask.id)
                XCTAssertEqual(rawTasksList.todos.first?.completed, mockRawTask.completed)
                XCTAssertEqual(rawTasksList.todos.first?.userId, mockRawTask.userId)
                
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Download should success, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - change task data
    func testUpdateTaskCompletionStatus_Success() throws {
        let expectation = XCTestExpectation(description: "Update Task Completion Status")
        
        // MARK: - prepare mock raw tasks list
        let mockRawTask = RawTask.getRawTask()
        let mockRawTaskList = [mockRawTask]
        
        // MARK: - save raw tasks list
        sut.saveLoadedTaskList(mockRawTaskList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // MARK: - update task completion status
                sut.updateTaskCompletionStatus(by: mockRawTask.id) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        // MARK: - fetch task after saving and verify it
                        mockStoreManager.fetchTask(by: mockRawTask.id) { result in
                            switch result {
                            case .success(let task):
                                XCTAssertEqual(task.id, mockRawTask.id)
                                XCTAssertEqual(task.completionStatus, !mockRawTask.completed)
                            case .failure(let error):
                                XCTFail("Fetching task should succeed, got error \(error)")
                            }
                        }
                        
                        // MARK: - remove task
                        mockStoreManager.removeTask(by: mockRawTask.id) { removeResult in
                            switch removeResult {
                            case .success:
                                break
                            case .failure(let error):
                                XCTFail("Remove task should succeed, got error: \(error)")
                            }
                        }
                        
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Updating should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Saving should succeed, got error \(error)")
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - remove task by ID
    func testRemoveTaskByID_Success() throws {
        let expectation = XCTestExpectation(description: "Remove Task By ID")
        
        // MARK: - prepare mock raw tasks list
        let mockRawTask = RawTask.getRawTask()
        let mockRawTaskList = [mockRawTask]
        
        // MARK: - save mock task
        sut.saveLoadedTaskList(mockRawTaskList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // MARK: - remove task by ID
                sut.removeTask(by: mockRawTask.id) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        // MARK: - check tasks list is empty after removing
                        sut.loadTasksListFromStorage { result in
                            switch result {
                            case .success(let tasksList):
                                XCTAssertEqual(tasksList.count, 0)
                                expectation.fulfill()
                            case .failure(let error):
                                XCTFail("Loading tasks list should succeed, got error \(error)")
                            }
                        }
                    case .failure(let error):
                        XCTFail("Removing should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Saving should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
