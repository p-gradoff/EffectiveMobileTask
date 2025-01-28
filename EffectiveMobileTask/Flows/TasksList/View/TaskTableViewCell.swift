//
//  TaskTableViewCell.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import UIKit
import SnapKit

// MARK: - saved alpha coefficient for UI elements
enum AlphaState {
    case full
    case half
}
extension AlphaState {
    var value: CGFloat {
        switch self {
        case .full: return 1
        case .half: return 0.5
        }
    }
}

// MARK: - cell that contains all about task
final class TaskTableViewCell: UITableViewCell {

    // MARK: - internal properties
    static let reuseID: String = UUID().uuidString
    
    var delegate: TaskTableViewCellDelegate!
    var indexPath: IndexPath!
    
    // MARK: - private property
    private var completionStatus: Bool!
    
    // MARK: - UI properties
    private lazy var titleLabel: UILabel = {
        $0.font = .getFont(fontType: .medium)
        $0.textColor = .primaryText
        $0.textAlignment = .left
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    private lazy var descriptionLabel: UILabel = {
        $0.font = .getFont(fontType: .regular, size: 12)
        $0.textColor = .primaryText
        $0.textAlignment = .left
        $0.numberOfLines = 2
        return $0
    }(UILabel())
    
    private lazy var dateLabel: UILabel = {
        $0.font = .getFont(fontType: .regular, size: 12)
        $0.textColor = .primaryText
        $0.alpha = AlphaState.half.value
        $0.textAlignment = .left
        return $0
    }(UILabel())
    
    private lazy var labelStack: UIStackView = { stack in
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        [titleLabel, descriptionLabel, dateLabel].forEach { label in
            stack.addArrangedSubview(label)
        }
        return stack
    }(UIStackView())
    
    private lazy var completionButton: UIButton = {
        $0.addTarget(self, action: #selector(changeCompletionStatus), for: .touchDown)
        return $0
    }(UIButton())
    
    @objc private func changeCompletionStatus(_ sender: UIButton) {
        completionStatus.toggle()
        completionStatus ? setupCompletedTask() : setupTaskInProgress()
        
        delegate?.doCompletionChanges(at: indexPath)
    }
    
    // MARK: - special undone task setup
    private func setupTaskInProgress() {
        titleLabel.attributedText = NSAttributedString(string: titleLabel.text!)
        titleLabel.alpha = AlphaState.full.value
        
        descriptionLabel.alpha = AlphaState.full.value
        completionButton.tintColor = .button
        completionButton.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    // MARK: - special completed task setup
    private func setupCompletedTask() {
        let attrStrikeThroughStyle: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]
        titleLabel.attributedText = NSAttributedString(string: titleLabel.text!, attributes: attrStrikeThroughStyle)
        titleLabel.alpha = AlphaState.half.value
        
        descriptionLabel.alpha = AlphaState.half.value
        completionButton.tintColor = .accent
        completionButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
    }
    
    // MARK: - cell setup based on item
    func setupCell(with item: Task) {
        backgroundColor = .clear
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none
        
        titleLabel.text = item.title
        descriptionLabel.text = item.content
        dateLabel.text = item.creationDate
        completionStatus = item.completionStatus
        
        completionStatus ? setupCompletedTask() : setupTaskInProgress()
        
        addSubviews(completionButton, labelStack)
        
        completionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        labelStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalTo(completionButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
        }
    }
    
    // MARK: - method that provides correct cell presenting
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.attributedText = nil
    }
}
