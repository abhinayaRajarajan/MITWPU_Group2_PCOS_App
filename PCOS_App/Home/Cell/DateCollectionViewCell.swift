//
//  DateCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewDateCell: UIView!

    private let todayIndicatorLabel = UILabel()

        var isToday: Bool = false {
            didSet { updateAppearance() }
        }

        override var isSelected: Bool {
            didSet { updateAppearance() }
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            
            // Setup container view
            viewDateCell.layer.cornerRadius = 20
            viewDateCell.clipsToBounds = true
            
            // Setup "Today" label
            todayIndicatorLabel.text = "Today"
            todayIndicatorLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            todayIndicatorLabel.textColor = .white
            todayIndicatorLabel.textAlignment = .center
            todayIndicatorLabel.isHidden = true
            
            viewDateCell.addSubview(todayIndicatorLabel)
            todayIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                todayIndicatorLabel.topAnchor.constraint(equalTo: viewDateCell.topAnchor, constant: 4),
                todayIndicatorLabel.centerXAnchor.constraint(equalTo: viewDateCell.centerXAnchor)
            ])
            
            // Setup fonts
            dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            
            // Clear background
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        func configureCell(date: CalendarDay) {
            dayLabel.text = date.day
            dateLabel.text = date.number
        }

        private func updateAppearance() {
            
            // Selected state (Today with pink fill)
            if isSelected {
                viewDateCell.backgroundColor = UIColor(red: 255/255, green: 143/255, blue: 171/255, alpha: 1) // Pink
                viewDateCell.layer.borderWidth = 0
                
                dayLabel.textColor = .white
                dateLabel.textColor = .white
                todayIndicatorLabel.isHidden = !isToday
                
                // Add drop shadow for selected
                viewDateCell.layer.shadowColor = UIColor.systemPink.cgColor
                viewDateCell.layer.shadowOffset = CGSize(width: 0, height: 4)
                viewDateCell.layer.shadowOpacity = 0.3
                viewDateCell.layer.shadowRadius = 8
                
            }
            // Today (but not selected) - dotted border
            else if isToday {
                viewDateCell.backgroundColor = .clear
                addDottedBorder()
                
                dayLabel.textColor = UIColor(red: 255/255, green: 143/255, blue: 171/255, alpha: 1)
                dateLabel.textColor = UIColor(red: 255/255, green: 143/255, blue: 171/255, alpha: 1)
                todayIndicatorLabel.isHidden = true
                
                viewDateCell.layer.shadowOpacity = 0
                
            }
            // Normal state - dotted border, light gray
            else {
                viewDateCell.backgroundColor = .clear
                addDottedBorder()
                
                dayLabel.textColor = UIColor.secondaryLabel
                dateLabel.textColor = UIColor.secondaryLabel
                todayIndicatorLabel.isHidden = true
                
                viewDateCell.layer.shadowOpacity = 0
            }
        }
        
        private func addDottedBorder() {
            // Remove existing border layers
            viewDateCell.layer.sublayers?.forEach { layer in
                if layer.name == "dottedBorder" {
                    layer.removeFromSuperlayer()
                }
            }
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.name = "dottedBorder"
            shapeLayer.strokeColor = UIColor.systemGray4.cgColor
            shapeLayer.lineWidth = 1.5
            shapeLayer.lineDashPattern = [3, 3] // Dotted pattern
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.path = UIBezierPath(roundedRect: viewDateCell.bounds, cornerRadius: 30).cgPath
            
            viewDateCell.layer.insertSublayer(shapeLayer, at: 0)
            viewDateCell.layer.borderWidth = 0 // Remove solid border
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            isToday = false
            
            // Remove dotted border layers
            viewDateCell.layer.sublayers?.forEach { layer in
                if layer.name == "dottedBorder" {
                    layer.removeFromSuperlayer()
                }
            }
            
            viewDateCell.layer.shadowOpacity = 0
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Update dotted border when layout changes
            if !isSelected {
                addDottedBorder()
            }
        }
    }
