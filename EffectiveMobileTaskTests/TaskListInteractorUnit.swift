//
//  TaskListInteractorUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 27.01.2025.
//

import XCTest
@testable import EffectiveMobileTask

final class TaskListInteractorUnit: XCTestCase {
    var taskListInteractor: TaskListInteractor!
    var storeManager: StoreManager!

    // MARK: - setup TaskListInteractorUnit
    override func setUp() {
        super.setUp()
        
        // MARK: - setup network manager's config
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let mockSession = URLSession(configuration: configuration)
        let networkManager = NetworkManager(urlSession: mockSession)
        
        // MARK: - setup test contexts to StoreManager
        let coreDataStack = CoreDataStack.shared
        storeManager = StoreManager(
            backgroundContext: coreDataStack.mainContext,
            mainContext: coreDataStack.mainContext
        )
        
        taskListInteractor = TaskListInteractor(networkManager: networkManager, storeManager: storeManager)
    }

    func testSaveLoadedTaskListSuccess() throws {
        let expectation = XCTestExpectation(description: "Save Loaded Task List Success")
        
        // MARK: - prepare mock task list
        let mockTaskID = 1
        let mockTaskContent = "Test content"
        let mockTaskCompletionStatus = true
        let mockTaskList = [
            RawTask(id: mockTaskID, todo: mockTaskContent, completed: mockTaskCompletionStatus, userId: 1)
        ]
        
        // MARK: - save task and checkout
        taskListInteractor.saveLoadedTaskList(mockTaskList) { [weak self] error in
            guard let self = self else { return }
            
            switch error {
            case nil:
                // MARK: - fetch created task and verify it
                storeManager.fetchTask(by: mockTaskID) { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success(let task):
                        XCTAssertEqual(mockTaskID, task.id)
                        XCTAssertEqual(mockTaskContent, task.content)
                        XCTAssertEqual(mockTaskCompletionStatus, task.completionStatus)
                    case .failure(let error):
                        XCTFail("Task not found, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: mockTaskID) { removeResult in
                        switch removeResult {
                        case .success:
                            break
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                    
                    expectation.fulfill()
                }
            default:
                XCTFail("Task should be saved, got error \(error!)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSaveLoadedTaskListBigAmount() throws {
        let expectation = XCTestExpectation(description: "Save Loaded Task List Success")
        
        // MARK: - prepare big task list
        let mockTaskContent = "Test content"
        let mockTaskCompletionStatus = true
        var mockTaskList = [RawTask]()
        
        let total = 100
        for counter in 0..<total {
            mockTaskList.append(
                RawTask(id: counter, todo: mockTaskContent, completed: mockTaskCompletionStatus, userId: counter)
            )
        }
        
        // MARK: - save task and checkout
        taskListInteractor.saveLoadedTaskList(mockTaskList) { [weak self] error in
            guard let self = self else { return }
            
            switch error {
            case nil:
                // MARK: - fetch created task and verify it
                storeManager.fetchTaskList { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success(let taskList):
                        XCTAssertEqual(taskList.count, total)
                    case .failure(let error):
                        XCTFail("Task not found, got error \(error)")
                    }
                    
                    // MARK: - remove task list
                    storeManager.removeAllTasks { deleteResult in
                        switch deleteResult {
                        case .success:
                            XCTAssert(true, "Deletion successfully done")
                        case .failure(let error):
                            XCTFail("Deletion failed, got error \(error)")
                        }
                    }
                    
                    expectation.fulfill()
                }
            default:
                XCTFail("Task should be saved, got error \(error!)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
