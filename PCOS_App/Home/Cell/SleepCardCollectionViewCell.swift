//
//  SleepCardCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

// MARK: - Delegate
protocol SleepCardCollectionViewCellDelegate: AnyObject {
    func sleepCardDidTapLogSleep(_ cell: SleepCardCollectionViewCell)
}

class SleepCardCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlet (existing from XIB)
    @IBOutlet weak var Card: UIView!

    // MARK: - Delegate
    weak var delegate: SleepCardCollectionViewCellDelegate?

    // MARK: - Programmatic subviews
    /// Stack shown when sleep has been logged
    private let dataStack = UIStackView()
    private let hoursLabel = UILabel()
    private let hoursSubLabel = UILabel()
    private let minLabel = UILabel()
    private let minSubLabel = UILabel()
    private let ratingLabel = UILabel()

    /// Full-width button shown when sleep has NOT been logged yet
    private let logSleepButton = UIButton(type: .system)

    private var isSetUp = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        Card.layer.cornerRadius = 20
        setupSubviews()
    }

    // MARK: - Setup
    private func setupSubviews() {
        guard !isSetUp else { return }
        isSetUp = true

        // ── Data stack (hours | min) ──────────────────────────────────────
        let hoursGroup = makeStatGroup(valueLabel: hoursLabel, subLabel: hoursSubLabel, sub: "hrs")
        let minGroup   = makeStatGroup(valueLabel: minLabel,   subLabel: minSubLabel,   sub: "min")

        let statsRow = UIStackView(arrangedSubviews: [hoursGroup, minGroup])
        statsRow.axis = .horizontal
        statsRow.spacing = 32
        statsRow.alignment = .center

        dataStack.axis = .vertical
        dataStack.spacing = 8
        dataStack.alignment = .center
        dataStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeLabel("Tonight's Sleep", size: 14, weight: .semibold, color: UIColor(hex: "#FE7A96"))
        dataStack.addArrangedSubview(titleLabel)
        dataStack.addArrangedSubview(statsRow)

        Card.addSubview(dataStack)

        NSLayoutConstraint.activate([
            dataStack.centerXAnchor.constraint(equalTo: Card.centerXAnchor),
            dataStack.centerYAnchor.constraint(equalTo: Card.centerYAnchor),
            dataStack.leadingAnchor.constraint(greaterThanOrEqualTo: Card.leadingAnchor, constant: 16),
            dataStack.trailingAnchor.constraint(lessThanOrEqualTo: Card.trailingAnchor, constant: -16)
        ])

        // ── Log Sleep Button ──────────────────────────────────────────────
        logSleepButton.setTitle("Log Your Sleep 🌙", for: .normal)
        logSleepButton.setTitleColor(.white, for: .normal)
        logSleepButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        logSleepButton.backgroundColor = UIColor(hex: "#FE7A96")
        logSleepButton.layer.cornerRadius = 20
        logSleepButton.translatesAutoresizingMaskIntoConstraints = false
        logSleepButton.addTarget(self, action: #selector(logSleepTapped), for: .touchUpInside)

        Card.addSubview(logSleepButton)

        NSLayoutConstraint.activate([
            logSleepButton.centerYAnchor.constraint(equalTo: Card.centerYAnchor),
            logSleepButton.leadingAnchor.constraint(equalTo: Card.leadingAnchor, constant: 20),
            logSleepButton.trailingAnchor.constraint(equalTo: Card.trailingAnchor, constant: -20),
            logSleepButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        // Start hidden; configure() calls will show the right one
        dataStack.isHidden = true
        logSleepButton.isHidden = true
    }

    // MARK: - Configure (sleep logged)
    func configure(with log: SleepLog) {
        dataStack.isHidden = false
        logSleepButton.isHidden = true

        hoursLabel.text = "\(log.hours)"
        minLabel.text   = String(format: "%02d", log.minutes)
    }

    // MARK: - Configure (not logged — show pink button)
    func configureNotLogged() {
        dataStack.isHidden = true
        logSleepButton.isHidden = false
    }

    // MARK: - Actions
    @objc private func logSleepTapped() {
        delegate?.sleepCardDidTapLogSleep(self)
    }

    // MARK: - Helpers
    private func makeStatGroup(valueLabel: UILabel, subLabel: UILabel, sub: String) -> UIView {
        valueLabel.text = "--"
        valueLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        valueLabel.textColor = UIColor(hex: "#2D2D2D")
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        subLabel.text = sub
        subLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subLabel.textColor = UIColor.systemGray
        subLabel.textAlignment = .center
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        let group = UIStackView(arrangedSubviews: [valueLabel, subLabel])
        group.axis = .vertical
        group.alignment = .center
        group.spacing = 2
        return group
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.textAlignment = .center
        return label
    }
}
