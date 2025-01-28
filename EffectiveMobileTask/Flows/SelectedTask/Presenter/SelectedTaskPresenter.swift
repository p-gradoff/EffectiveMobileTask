//
//  SelectedTaskPresenter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation

// MARK: - handles requests and coordinates the work of the view and the interactor
final class SelectedTaskPresenter {
    
    // MARK: - private properties
    private let view: SelectedTaskViewInput
    private let interactor: SelectedTaskInteractorInput
    
    // MARK: - init
    init(view: SelectedTaskViewInput, interactor: SelectedTaskInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    // MARK: - sends a request to the interactor to get task by ID
    func setTask(by id: Int) {
        interactor.getTask(by: id)
    }
}

// MARK: - handles requests from the view
extension SelectedTaskPresenter: SelectedTaskViewOutput {
    // MARK: - sends a request to the interactor to get table data
    func getTableEditionData() {
        interactor.getTableData()
    }
}

// MARK: - handles requests from the interactor
extension SelectedTaskPresenter: SelectedTaskInteractorOutput {
    func sendError(with message: String, _ title: String) {
        view.presentAlertController(with: message, title)
    }
    
    // MARK: - passes task from the interactor to the view
    func sendTask(_ task: Task) {
        view.setSelectedTask(task)
    }
    
    // MARK: - passes table data from the interactor to the view
    func sendData(_ data: [TaskEdition]) {
        view.setTaskEditionTableData(with: data)
    }
}
