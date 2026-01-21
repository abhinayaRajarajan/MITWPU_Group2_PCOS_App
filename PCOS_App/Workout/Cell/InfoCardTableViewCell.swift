//
//  InfoCardTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class InfoCardTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        selectionStyle = .none
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = false
    }

    func configure(items: [String]) {
        infoLabel.text = items.map { " \($0)" }.joined(separator: "\n")
    }
}
