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
                XCTFail("Creation should succeed, got error \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTaskByIDTaskNotFound() throws {
        let expectation = XCTestExpectation(description: "Fetch task by ID but not found")
        
        
    }
}
