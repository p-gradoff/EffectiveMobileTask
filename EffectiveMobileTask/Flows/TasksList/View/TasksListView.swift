//
//  TaskListView.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import UIKit

// MARK: - input funcs
protocol TasksListViewInput: AnyObject {
    var output: TasksListViewOutput? { get set }
    func setTableData(with data: [Task])
    func presentAlertController(with message: String, _ title: String)
}

// MARK: - output funcs
protocol TasksListViewOutput: AnyObject {
    func getTasks()
    func changeTaskCompletionStatus(by id: Int)
    func openSelectedTaskCell(by id: Int)
    func createNewTask()
    func openTaskEditor(by id: Int)
    func removeTask(by id: Int)
}

// MARK: - delegate that sends requests to save changes
protocol TaskTableViewCellDelegate: AnyObject {
    func doCompletionChanges(at indexPath: IndexPath)
}

// MARK: - ViewController that presents task list
final class TasksListView: UIViewController, UISearchResultsUpdating {

    // MARK: - delegate property
    var output: TasksListViewOutput?
    
    // MARK: - private properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var tableData: [Task] = []
    private var filteredData: [Task] = []
    
    // MARK: - UI properties
    private lazy var tableView: UITableView = {
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.separatorInset = .zero
        $0.separatorStyle = .singleLine
        $0.separatorColor = .button
        $0.layoutMargins = .zero
        $0.bounces = false
        $0.rowHeight = UITableView.automaticDimension
        $0.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseID)
        return $0
    }(UITableView())
    
    private let bottomView: UIView = {
        $0.backgroundColor = .additionTheme
        return $0
    }(UIView())
    
    private lazy var taskCounter: UILabel = {
        $0.textColor = .primaryText
        $0.textAlignment = .left
        $0.font = .getFont(fontType: .regular, size: 11)
        return $0
    }(UILabel())
    
    private lazy var taskLabel: UILabel = {
        $0.textColor = .primaryText
        $0.text = "Задач"
        $0.textAlignment = .left
        $0.font = .getFont(fontType: .regular, size: 11)
        return $0
    }(UILabel())
    
    private lazy var taskLabelStack: UIStackView = { stack in
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .equalSpacing
        [taskCounter, taskLabel].forEach { label in
            stack.addArrangedSubview(label)
        }
        return stack
    }(UIStackView())
    
    private lazy var createButton: UIButton = {
        $0.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .accent
        $0.addTarget(self, action: #selector(createButtonTapped(sender: )), for: .touchDown)
        return $0
    }(UIButton())
    
    // MARK: - send a request to the presenter to create new task
    @objc private func createButtonTapped(sender: UIButton) {
        output?.createNewTask()
    }
    
    // MARK: - view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupSearchController()
        setupView()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        output?.getTasks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .primaryText.withAlphaComponent(0.5)
        }
    }
    
    // MARK: - views initializing
    private func setupView() {
        view.backgroundColor = .mainTheme
        view.addSubviews(tableView, bottomView)
        bottomView.addSubviews(taskLabelStack, createButton)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        taskLabelStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(13)
        }
        
        createButton.snp.makeConstraints {
            $0.centerY.equalTo(taskLabelStack.snp.centerY)
            $0.trailing.equalToSuperview().inset(40)
            $0.width.height.equalTo(20)
        }
    }
    
    // MARK: - navigation controller setup
    private func setupNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        title = "Задачи"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryText]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - search controller setup
    private func setupSearchController() {
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [
                NSAttributedString.Key.font : UIFont.getFont(fontType: .regular, size: 17),
                NSAttributedString.Key.foregroundColor : UIColor.button
            ]
        )
        searchController.searchBar.tintColor = .primaryText
        searchController.searchBar.searchTextField.backgroundColor = .additionTheme
        navigationItem.searchController = searchController
    }
    
    // MARK: - method that manages table data filtering and reloading
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterTableData(text)
        tableView.reloadData()
    }
    
    // MARK: - asynchronously filters the table data and then updates it
    private func filterTableData(_ searchText: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let filtered = tableData.filter { $0.title.contains(searchText) || $0.content.contains(searchText) }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                filteredData = filtered
                tableView.reloadData()
            }
        }
    }
}

// MARK: - tasks table view methods
extension TasksListView: UITableViewDataSource, UITableViewDelegate, TaskTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: - send a request to the presenter when table data is empty to load it
        let count = tableData.count
        if count == 0 {
            output?.getTasks()
        }
        taskCounter.text = String(count)
        
        // MARK: - display the filtered data or not depending on the search controller and search bar
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return filteredData.count
        } else {
            return tableData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseID, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        // MARK: - configure cell depending on search controller and search bar
        var item: Task!
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            item = filteredData[indexPath.row]
        } else {
            item = tableData[indexPath.row]
        }
        cell.setupCell(with: item)
        return cell
    }
    
    // MARK: - send a request to the presenter to open selected task
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = tableData[indexPath.row]
        output?.openSelectedTaskCell(by: selectedTask.id)
    }
    
    // MARK: - send a request to the presenter to save task with changed completion status
    func doCompletionChanges(at indexPath: IndexPath) {
        let id = tableData[indexPath.row].id
        output?.changeTaskCompletionStatus(by: id)
    }
}

// MARK: - send view the information and present alert
extension TasksListView: TasksListViewInput, AlertProtocol {
    
    // MARK: - show error's information
    func presentAlertController(with message: String, _ title: String) {
        let controller = getAlertController(withMessage: message, title: title)
        self.present(controller, animated: true)
    }
    
    // MARK: - set loaded data and reload tableView
    func setTableData(with data: [Task]) {
        tableData = data
        tableView.reloadData()
    }
}

// MARK: - method to manage selected task dismissing and then sending a request to the presenter depending on action type by ID
extension TasksListView: DismissDelegate {
    func dismissController(withAction action: TaskEditionRequestCollection?, taskId id: Int?) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            guard let action, let id else {
                return
            }
            switch action {
            case .edit:
                output?.openTaskEditor(by: id)
            case .share:
                break
            case .remove:
                output?.removeTask(by: id)
                output?.getTasks()
            }
        }
    }
}

