//
//  StoreManagerUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 26.01.2025.
//

import XCTest
import CoreData
@testable import EffectiveMobileTask

// MARK: - manages all test operations on the storeManager
final class StoreManagerUnit: XCTestCase {
    
    // MARK: - properties
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
    
    // MARK: - setup storeManagerUnit
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack.shared
        // MARK: - setup test contexts to StoreManager
        storeManager = StoreManager(
            backgroundContext: coreDataStack.mainContext,
            mainContext: coreDataStack.mainContext
        )
    }
    
    // MARK: - create a task and verify its creation
    func testCreateTaskSuccess() throws {
        let expectation = XCTestExpectation(description: "Success Task creation")
        
        // MARK: - prepare test task and create it
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
                // MARK: - try to fetch test task and verify it
                storeManager.fetchTask(by: testTask.id) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let task):
                        // MARK: - verify task
                        XCTAssertEqual(task.id, testTask.id)
                        XCTAssertEqual(task.creationDate, testTask.creationDate)
                        XCTAssertEqual(task.content, testTask.content)
                        XCTAssertEqual(task.completionStatus, testTask.completionStatus)
                    case .failure(let error):
                        // MARK: - expected task not found case
                        XCTFail("Fetching should succeed, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: testTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - creation error
                XCTFail("Creation should succeed, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - create task and try to set incorrect ID
    func testCreateTaskWrongID() throws {
        let expectation = XCTestExpectation(description: "Failure Task creation")
        
        // MARK: - prepare test task and create it
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        var testTask = TestTask.getTestTask()
        // MARK: - wrong ID setup
        testTask.id = -10
        
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
                // MARK: - creation done with incorrect id
                XCTFail("Creation should fail")
                // MARK: - remove task
                storeManager.removeTask(by: testTask.id) { removeResult in
                    switch removeResult {
                    case .success:
                        XCTAssert(true, "Success remove")
                    case .failure(let error):
                        XCTFail("Remove task should succeed, got error: \(error)")
                    }
                }
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - try to create task with wrong entity description
    func testCreateTaskWrongEntityDescription() throws {
        let expectation = XCTestExpectation(description: "Failue task creation")
        
        // MARK: - prepare test task and create it
        // MARK: - setup wrong entity description
        let testEntityDescription = storeManager.formEntityDescription("Wrong entity name", context: storeManager.backgroundContext)
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
                // MARK: - creation done with wrong entity description
                XCTFail("Creation should fail")
                // MARK: - remove task
                storeManager.removeTask(by: testTask.id) { removeResult in
                    switch removeResult {
                    case .success:
                        XCTAssert(true, "Success remove")
                    case .failure(let error):
                        XCTFail("Remove task should succeed, got error: \(error)")
                    }
                }
            case .failure(let error):
                XCTAssertEqual(error, .creationError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - create 2 tasks and try to find certain task by ID
    func testFetchTaskByIDSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch task by ID success")
        
        // MARK: - prepare 2 tasks
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTaskFirst = TestTask.getTestTask()
        var testTaskSecond = TestTask.getTestTask()
        // MARK: - ID to find
        testTaskSecond.id = 2
        
        // MARK: - first task creation
        storeManager.createTask(
            taskDescription: testEntityDescription,
            with: testTaskFirst.id,
            creationDate: testTaskFirst.creationDate,
            content: testTaskFirst.content,
            completionStatus: testTaskFirst.completionStatus
        ) { _ in }
        
        // MARK: - second task creation
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
                storeManager.fetchTask(by: testTaskSecond.id) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let task):
                        // MARK: - verify task
                        XCTAssertEqual(task.id, testTaskSecond.id)
                        XCTAssertEqual(task.creationDate, testTaskSecond.creationDate)
                        XCTAssertEqual(task.content, testTaskSecond.content)
                        XCTAssertEqual(task.completionStatus, testTaskSecond.completionStatus)
                    case .failure(let error):
                        // MARK: - fetch second task by ID failed
                        XCTFail("Fetching should succeed, got error \(error)")
                    }
                    
                    // MARK: - remove first task
                    storeManager.removeTask(by: testTaskFirst.id) { removeResult in
                        switch removeResult {
                        case .success:
                            XCTAssert(true, "Success remove")
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                    
                    // MARK: - remove second task
                    storeManager.removeTask(by: testTaskSecond.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - second task creation failed
                XCTFail("Creation should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to get task by non-existent ID
    func testFetchTaskByIDTaskNotFound() throws {
        let expectation = XCTestExpectation(description: "Fetch task by ID but not found")
        
        // MARK: - prepare test task and create it
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
                storeManager.fetchTask(by: -1) { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success:
                        // MARK: - got task by non-existent ID
                        XCTFail("Fetch should fail")
                    case .failure(let error):
                        XCTAssertEqual(error, .taskNotFound)
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: testTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Fetch task by wrong ID should not fail with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - create task and get task list
    func testFetchTaskListSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch task list success")
        
        // MARK: - prepare test task and create it
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
                storeManager.fetchTaskList { [weak self] fetchResult in
                    guard let self = self else { return }
                    
                    switch fetchResult {
                    case .success(let taskList):
                        // MARK: - verify task list count
                        XCTAssertEqual(taskList.count, 1)
                    case .failure(let error):
                        // MARK: - task list not found
                        XCTFail("Fetch task list should succeed, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: testTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Fetch task list should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - create task and update data
    func testUpdateTaskDataSuccess() throws {
        let expectation = XCTestExpectation(description: "Update task data success")
        
        // MARK: - prepare task and create it
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        
        // MARK: - task changes
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
                storeManager.updateTask(
                    with: testTaskChangeFilling,
                    by: testTask.id
                ) { [weak self] updateResult in
                    guard let self = self else { return }
                    
                    switch updateResult {
                    case .success(let changedTask):
                        // MARK: - verify changes
                        XCTAssertEqual(changedTask.title, newTestTitle)
                        XCTAssertEqual(changedTask.content, newTestContent)
                    case .failure(let error):
                        // MARK: - task update failed
                        XCTFail("Update task should succeed, got error \(error)")
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: testTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Creation task should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to update task by incorrect ID
    func testUpdateTestDataTaskNotFound() throws {
        let expectation = XCTestExpectation(description: "Update test data task not found")
        
        // MARK: - prepare task and create it
        let testEntityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
        let testTask = TestTask.getTestTask()
        let testTaskChange = TaskChange.completionStatus
        
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
                storeManager.updateTask(with: testTaskChange, by: 2) { [weak self] updateResult in
                    guard let self = self else { return }
                    
                    switch updateResult {
                    case .success:
                        // MARK: - task updated by incorrect ID
                        XCTFail("Update test data should fail")
                    case .failure(let error):
                        XCTAssertEqual(error, .taskNotFound)
                    }
                    
                    // MARK: - remove task
                    storeManager.removeTask(by: testTask.id) { removeResult in
                        switch removeResult {
                        case .success:
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("Remove task should succeed, got error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Update task should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - create task and remove it
    func testRemoveTaskSuccess() throws {
        let expectation = XCTestExpectation(description: "Remove Task Success")
        
        // MARK: - prepare task and create it
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
                                // MARK: - verify task list is empty after task remove
                                XCTAssert(taskList.isEmpty)
                                expectation.fulfill()
                            case .failure(let error):
                                // MARK: - fetch task list failed
                                XCTFail("Fetch Task list failed, got error: \(error)")
                            }
                        }
                    case .failure(let error):
                        // MARK: - remove task by ID failed
                        XCTFail("Remove Test Task should succeed, got error \(error)")
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Remove Test Task should succeed, got error \(error)")
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - try to remove task by ID
    func testRemoveTaskWrongID() {
        let expectation = XCTestExpectation(description: "Remove Task by wrong ID")
        
        // MARK: - prepare task and create it
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
                        // MARK: - task removed by wrong ID
                        XCTFail("Remove Task by wrong ID should fail")
                    case .failure(let error):
                        XCTAssertEqual(error, .taskNotFound)
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                // MARK: - task creation failed
                XCTFail("Creation task should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
