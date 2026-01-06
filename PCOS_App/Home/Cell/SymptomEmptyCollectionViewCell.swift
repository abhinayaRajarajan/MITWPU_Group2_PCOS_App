//
//  SymptomEmptyCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class SymptomEmptyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 16
        
        messageLabel.text = "Add Symptoms"
//        messageLabel.textColor = .systemGray3
        
        //messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    

}
