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

    @IBOutlet weak var headingCard: UILabel!
    
    @IBOutlet weak var iconLabel: UIImageView!
    @IBOutlet weak var Card: UIView!

    weak var delegate: SleepCardCollectionViewCellDelegate?

    @IBOutlet weak var hoursSubLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    @IBOutlet weak var minsLabel: UILabel!
    
    @IBOutlet weak var minsSubLabel: UILabel!
    
    @IBOutlet weak var sleepObservationLabel: UILabel!
    
    // Data stack (shown when sleep is logged)
        private let dataStack = UIStackView()
//        private let hoursLabel = UILabel()
//        private let hoursSubLabel = UILabel()
//        private let minLabel = UILabel()
//        private let minSubLabel = UILabel()

    private let logSleepButton = UIButton(type: .system)
        private var isSetUp = false

        // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
            Card.layer.cornerRadius = 20
            setupButton()
        }

        // MARK: - Setup button only (XIB handles data labels layout)
        private func setupButton() {
            guard !isSetUp else { return }
            isSetUp = true

            logSleepButton.setTitle("Log Your Sleep 🌙", for: .normal)
            logSleepButton.setTitleColor(.white, for: .normal)
            logSleepButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            logSleepButton.backgroundColor = UIColor(hex: "#FE7A96")
            logSleepButton.layer.cornerRadius = 20
            logSleepButton.translatesAutoresizingMaskIntoConstraints = false
            logSleepButton.addTarget(
                self,
                action: #selector(logSleepTapped),
                for: .touchUpInside
            )

            Card.addSubview(logSleepButton)

            NSLayoutConstraint.activate([
                logSleepButton.centerYAnchor.constraint(equalTo: Card.centerYAnchor),
                logSleepButton.leadingAnchor.constraint(
                    equalTo: Card.leadingAnchor, constant: 20
                ),
                logSleepButton.trailingAnchor.constraint(
                    equalTo: Card.trailingAnchor, constant: -20
                ),
                logSleepButton.heightAnchor.constraint(equalToConstant: 52)
            ])

            // Hidden by default
            logSleepButton.isHidden = true
        }

        // MARK: - Configure
        func configure(with log: SleepLog?) {
            if let log = log {
                // Sleep logged → show all XIB data labels, hide button
                headingCard.isHidden = false
                iconLabel.isHidden = false
                hoursLabel.isHidden = false
                hoursSubLabel.isHidden = false
                minsLabel.isHidden = false
                minsSubLabel.isHidden = false
                sleepObservationLabel.isHidden = false
                logSleepButton.isHidden = true

                hoursLabel.text = "\(log.hours)"
                minsLabel.text = String(format: "%02d", log.minutes)
                sleepObservationLabel.text = sleepObservation(for: log.hours)
            } else {
                // No sleep logged → hide all XIB data labels, show button only
                headingCard.isHidden = true
                iconLabel.isHidden = true
                hoursLabel.isHidden = true
                hoursSubLabel.isHidden = true
                minsLabel.isHidden = true
                minsSubLabel.isHidden = true
                sleepObservationLabel.isHidden = true
                logSleepButton.isHidden = false
            }
        }

        // MARK: - Actions
        @objc private func logSleepTapped() {
            delegate?.sleepCardDidTapLogSleep(self)
        }

        // MARK: - Helpers
        private func sleepObservation(for hours: Int) -> String {
            switch hours {
            case ..<5:
                return "You slept very little. Try to rest more tonight."
            case 5..<6:
                return "Below recommended sleep. Aim for 7-8 hours."
            case 6..<7:
                return "Almost there! A little more sleep would help."
            case 7...8:
                return "Great sleep! This supports hormone balance."
            default:
                return "You slept more than usual. Listen to your body."
            }
        }
    }
