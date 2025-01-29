//
//  TaskPageView.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import UIKit

import UIKit
import SnapKit

// MARK: - view that allows you to edit a new or existing task

protocol TaskPageViewInput: AnyObject {
    var output: TaskPageViewOutput? { get set }
    func setTask(_ task: Task)
    func presentAlertController(with message: String, _ title: String)
}

protocol TaskPageViewOutput: AnyObject {
    func saveChanges(from title: String, _ description: String, with id: Int)
}

final class TaskPageView: UIViewController, UITextViewDelegate {
    // MARK: - output is presenter
    var output: TaskPageViewOutput?
    
    // MARK: - private properties
    private var taskData: Task!
    private let descriptionPlaceholder: String = "Task description"
    
    // MARK: - UI properties
    private let descriptionTextView: UITextView = {
        $0.textColor = .primaryText
        $0.font = .getFont(fontType: .regular)
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        return $0
    }(UITextView())
    
    private let titleTextField: UITextField = {
        $0.textColor = .primaryText
        $0.font = .getFont(fontType: .bold, size: 34)
        $0.textAlignment = .left
        
        let placeholderAttributes = NSAttributedString(string: "Title", attributes: [
            NSAttributedString.Key.font : UIFont.getFont(fontType: .bold, size: 34),
            NSAttributedString.Key.foregroundColor : UIColor.button
        ])
        $0.attributedPlaceholder = placeholderAttributes
        return $0
    }(UITextField())
    
    private let dateLabel: UILabel = {
        $0.font = .getFont(fontType: .regular, size: 12)
        $0.textColor = .primaryText.withAlphaComponent(0.5)
        $0.textAlignment = .left
        return $0
    }(UILabel())
    
    // MARK: - view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .accent
        navigationItem.largeTitleDisplayMode = .never
        descriptionTextView.delegate = self
        setupView()
    }
//    
//    override func viewIsAppearing(_ animated: Bool) {
//        super.viewIsAppearing(animated)
//        // MARK: - load actual view's data before presenting
//        updateViews()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // MARK: - sends a request to the presenter to save changes of task's data by ID
        var titleText = String()
        if titleTextField.text == nil || titleTextField.text == "" {
            titleText = "TO-DO"
        } else {
            titleText = titleTextField.text!
        }
        
        output?.saveChanges(
            from: titleText, descriptionTextView.text,
            with: taskData.id
        )
    }
    
    // MARK: - views initialization
    private func setupView() {
        view.backgroundColor = .mainTheme
        setupDescriptionTextView()
        view.addSubviews(titleTextField, dateLabel, descriptionTextView)
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - updates the data, if any
    private func setupDescriptionTextView() {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = descriptionPlaceholder
            descriptionTextView.textColor = .primaryText.withAlphaComponent(0.5)
        }
    }
    
    // MARK: - the method that the placeholder applies or does not apply to the task description
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.text == descriptionPlaceholder {
            descriptionTextView.text = ""
            descriptionTextView.textColor = .primaryText
        }
    }
}

// MARK: - methods that allows the view to get information
extension TaskPageView: TaskPageViewInput, AlertProtocol {
    
    // MARK: - show error's information
    func presentAlertController(with message: String, _ title: String) {
        let controller = getAlertController(withMessage: message, title: title)
        self.present(controller, animated: true)
    }
    
    // MARK: - set received data
    func setTask(_ task: Task) {
        taskData = task
    }
}
