//
//  SelectedTaskInteractor.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation

// MARK: - process requests to receive and send data from the presenter and view
protocol SelectedTaskInteractorInput: AnyObject {
    var output: SelectedTaskInteractorOutput? { get }
    func getTableData()
    func getTask(by id: Int)
}

protocol SelectedTaskInteractorOutput: AnyObject {
    func sendData(_ data: [TaskEdition])
    func sendTask(_ task: Task)
    func sendError(with message: String, _ title: String)
}

final class SelectedTaskInteractor: SelectedTaskInteractorInput {
    // MARK: - output is presenter
    weak var output: SelectedTaskInteractorOutput?
    
    // MARK: - private property
    private let storeManager: StoreManagerOutput
    
    // MARK: - init
    init(storeManager: StoreManagerOutput) {
        self.storeManager = storeManager
    }
    
    // MARK: - sends a request to the EditData structure to get tableData and then send it to view via presenter
    func getTableData() {
        let data = TaskEdition.getTaskEditionCase()
        output?.sendData(data)
    }
    
    // MARK: - send a request to the store manager to get task by ID and then send it to view via presenter
    func getTask(by id: Int) {
        storeManager.fetchTask(by: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let task):
                output?.sendTask(task)
            case .failure(let error):
                output?.sendError(with: error.localizedDescription, Errors.coreData.value)
            }
        }
    }
}
