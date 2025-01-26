//
//  StoreManagerUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 26.01.2025.
//

import XCTest
import CoreData
@testable import EffectiveMobileTask

final class StoreManagerUnit: XCTestCase {
    var storeManager: StoreManager!
    var coreDataStack: CoreDataStack!
    
    struct TestTask {
        var id: Int
        let creationDate: String
        let content: String
        let completionStatus: Bool
        
        static func getTestTask() -> TestTask {
            TestTask(id: 1, creationDate: "2025-01-26", content: "Test Content", completionStatus: false)
        }
    }
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack()
        storeManager = StoreManager(backgroundContext: coreDataStack.mainContext, mainContext: coreDataStack.mainContext)
    }
    
    func testCreateTaskSuccess() throws {
        let expectation = XCTestExpectation(description: "Success Task creation")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus)
        { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.fetchTask(by: testTask.id) { result in
                    switch result {
                    case .success(let task):
                        XCTAssertEqual(task.id, testTask.id)
                        XCTAssertEqual(task.creationDate, testTask.creationDate)
                        XCTAssertEqual(task.content, testTask.content)
                        XCTAssertEqual(task.completionStatus, testTask.completionStatus)
                        
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Fetching should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Creation should succeed, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testCreateTaskWrongID() throws {
        let expectation = XCTestExpectation(description: "Failure Task creation")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        var testTask = TestTask.getTestTask()
        testTask.id = -10
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus)
        { result in
            switch result {
            case .success:
                XCTFail("Creation should fail")
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        
    }
    
    func testCreateTaskWrongEntityDescription() throws {
        let expectation = XCTestExpectation(description: "Failue task creation")
        
        let testEntityDescription = storeManager.formEntityDescription("Wrong entity name", context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus)
        { result in
            switch result {
            case .success:
                XCTFail("Creation should fail")
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchTaskByIDSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch task by ID success")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTaskFirst = TestTask.getTestTask()
        var testTaskSecond = TestTask.getTestTask()
        testTaskSecond.id = 2
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTaskFirst.id,
            creationDate: testTaskFirst.creationDate,
            content: testTaskFirst.content,
            completionStatus: testTaskFirst.completionStatus
        )
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTaskSecond.id,
            creationDate: testTaskSecond.creationDate,
            content: testTaskSecond.content,
            completionStatus: testTaskSecond.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.fetchTask(by: testTaskSecond.id) { result in
                    switch result {
                    case .success(let task):
                        XCTAssertEqual(task.id, testTaskSecond.id)
                        XCTAssertEqual(task.creationDate, testTaskSecond.creationDate)
                        XCTAssertEqual(task.content, testTaskSecond.content)
                        XCTAssertEqual(task.completionStatus, testTaskSecond.completionStatus)
                        
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Fetching should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Creation should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTaskByIDTaskNotFound() throws {
        let expectation = XCTestExpectation(description: "Fetch task by ID but not found")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.fetchTask(by: -1) { fetchResult in
                    switch fetchResult {
                    case .success:
                        XCTFail("Fetch should fail")
                    case .failure(let error):
                        XCTAssertEqual(error, .taskNotFound)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Fetch task by wrong ID should not fail with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTaskListSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch task list success")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.fetchTaskList { fetchResult in
                    switch fetchResult {
                    case .success(let taskList):
                        XCTAssertEqual(taskList.count, 1)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Fetch task list should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Fetch task list should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateTaskDataSuccess() throws {
        let expectation = XCTestExpectation(description: "Update task data success")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        let newTestTitle = "New Test Title"
        let newTestContent = "New Test Content"
        let testTaskChangeFilling = TaskChange.content(title: newTestTitle, content: newTestContent)
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.updateTask(with: testTaskChangeFilling, by: testTask.id) { updateResult in
                    switch updateResult {
                    case .success(let changedTask):
                        XCTAssertEqual(changedTask.title, newTestTitle)
                        XCTAssertEqual(changedTask.content, newTestContent)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Update task should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Update task should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateTestDataTaskNotFound() throws {
        let expectation = XCTestExpectation(description: "Update test data task not found")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        let testTaskChange = TaskChange.completionStatus
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        )
        
        storeManager.updateTask(with: testTaskChange, by: 2) { result in
            switch result {
            case .success:
                XCTFail("Update test data should fail")
            case .failure(let error):
                XCTAssertEqual(error, .taskNotFound)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRemoveTaskSuccess() throws {
        let expectation = XCTestExpectation(description: "Remove Task Success")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.removeTask(by: testTask.id) { [weak self] removeResult in
                    guard let self = self else { return }
                    
                    switch removeResult {
                    case .success:
                        storeManager.fetchTaskList { fetchResult in
                            switch fetchResult {
                            case .success(let taskList):
                                XCTAssert(taskList.isEmpty)
                                expectation.fulfill()
                            case .failure(let error):
                                XCTFail("Fetch Task list failed, got error: \(error)")
                            }
                        }
                    case .failure(let error):
                        XCTFail("Remove Test Task should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("Remove Test Task should succeed, got error \(error)")
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRemoveTaskWrongID() {
        let expectation = XCTestExpectation(description: "Remove Task by wrong ID")
        
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTask.id,
            creationDate: testTask.creationDate,
            content: testTask.content,
            completionStatus: testTask.completionStatus
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                storeManager.removeTask(by: 2) { removeResult in
                    switch removeResult {
                    case .success:
                        XCTFail("Remove Task by wrong ID should fail")
                    case .failure(let error):
                        XCTAssertEqual(error, .taskNotFound)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Remove Task by wrong ID should not fail with error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
