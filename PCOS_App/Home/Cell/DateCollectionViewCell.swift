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

    var isToday: Bool = false {
            didSet { updateAppearance() }
        }

        override var isSelected: Bool {
            didSet { updateAppearance() }
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            
            viewDateCell.layer.cornerRadius = 35
            viewDateCell.clipsToBounds = true
            
            // Remove debug colors
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        func configureCell(date: CalendarDay) {
            dayLabel.text = date.day
            dateLabel.text = date.number
        }

        private func updateAppearance() {
            if isSelected {
                viewDateCell.backgroundColor = UIColor(
                    red: 255/255, green: 115/255, blue: 148/255, alpha: 1  // Pink for selected
                )
                viewDateCell.layer.borderWidth = 0
                dayLabel.textColor = .white
                dateLabel.textColor = .white

            } else if isToday {
                viewDateCell.backgroundColor = UIColor(
                    red: 255/255, green: 200/255, blue: 215/255, alpha: 1  // Light pink
                )
                viewDateCell.layer.borderWidth = 2
                viewDateCell.layer.borderColor = UIColor(
                    red: 255/255, green: 115/255, blue: 148/255, alpha: 1
                ).cgColor
                dayLabel.textColor = .label
                dateLabel.textColor = .label

            } else {
                viewDateCell.backgroundColor = UIColor(
                    red: 245/255, green: 245/255, blue: 247/255, alpha: 1  // Light gray
                )
                viewDateCell.layer.borderWidth = 0
                dayLabel.textColor = .secondaryLabel
                dateLabel.textColor = .secondaryLabel
            }
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            isToday = false
            viewDateCell.layer.borderWidth = 0
        }
    }
