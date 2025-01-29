//
//  SelectedTaskInteractorUnit.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 29.01.2025.
//

import XCTest
import CoreData
@testable import EffectiveMobileTask

/*
 final class MockStoreManagerSuccess: StoreManager {
 let content = "Test Content"
 let completionStatus = true
 let creationDate = "2025/01/29"
 
 override func fetchTask(by id: Int, completion: @escaping ((Result<Task, CoreDataError>) -> Void)) {
 guard id >= 0 else {
 completion(.failure(.fetchError))
 return
 }
 let testEntityDescription = formEntityDescription(TaskParameter.name.value, context: backgroundContext)!
 let task = Task(entity: testEntityDescription, insertInto: backgroundContext)
 
 task.setupTask(id: id, creationDate: creationDate, content: content, completionStatus: completionStatus)
 
 completion(.success(task))
 }
 }
 
 final class MockSelectedInteractorOutput: SelectedTaskInteractorOutput {
 var sendTaskResult: Task?
 var errorDescription: String?
 var errorType: String?
 var isData: Bool = false
 
 func sendData(_ data: [TaskEdition]) {
 isData.toggle()
 }
 
 func sendTask(_ task: Task) {
 sendTaskResult = task
 }
 
 func sendError(with message: String, _ title: String) {
 errorDescription = message
 errorType = title
 }
 }
 
 final class SelectedTaskInteractorUnit: XCTestCase {
 var sut: SelectedTaskInteractor!
 var mockStoreManager: MockStoreManagerSuccess!
 var mockOutput: MockSelectedInteractorOutput!
 
 override func setUp() {
 let mockStoreManager = MockStoreManagerSuccess(backgroundContext: CoreDataStack.shared.backgroundContext, mainContext: CoreDataStack.shared.mainContext)
 let mockOutput = MockSelectedInteractorOutput()
 
 sut = SelectedTaskInteractor(storeManager: mockStoreManager)
 sut.output = mockOutput
 
 self.mockStoreManager = mockStoreManager
 self.mockOutput = mockOutput
 }
 
 func testGetTask_Success() throws {
 let expectation = XCTestExpectation(description: "Get Task Success")
 
 let mockID = 1
 sut.getTask(by: mockID)
 
 guard let sendTaskResult = mockOutput.sendTaskResult else {
 XCTFail("Sending task should succeed, got error")
 return
 }
 XCTAssertEqual(sendTaskResult.content, mockStoreManager.content)
 XCTAssertEqual(sendTaskResult.completionStatus, mockStoreManager.completionStatus)
 
 expectation.fulfill()
 wait(for: [expectation], timeout: 1.0)
 }
 
 func testGetTask_Failure() throws {
 let expectation = XCTestExpectation(description: "Get Task Failure")
 
 let mockID = -1
 sut.getTask(by: mockID)
 
 guard let errorDescription = mockOutput.errorDescription, let errorType = mockOutput.errorType else {
 XCTFail("Getting task should fail")
 return
 }
 XCTAssertEqual(errorDescription, CoreDataError.fetchError.localizedDescription)
 XCTAssertEqual(errorType, Errors.coreData.value)
 expectation.fulfill()
 
 wait(for: [expectation], timeout: 1.0)
 }
 
 func testGetTableData_Success() throws {
 sut.getTableData()
 
 if mockOutput.isData == true {
 XCTAssert(true)
 } else {
 XCTFail("Getting Table Data Should Succeed")
 }
 }
 }
 */
