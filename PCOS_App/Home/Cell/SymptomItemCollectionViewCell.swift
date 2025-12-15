//
//  SymptomItemCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//

import UIKit

class SymptomItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var IconImage: UIImageView!
    @IBOutlet weak var symptomLabel: UILabel!
    
    static let identifier = "SymptomItemCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if IconImage != nil && symptomLabel != nil {
                setupUI()
            }
    }
    
    private func setupUI(){
        // Cell background and corners
        contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 20
            contentView.clipsToBounds = true
            
            // Icon setup - circular white background
            IconImage?.layer.cornerRadius = 25 // Will be 50x50, so half is 25
            IconImage?.clipsToBounds = true
            IconImage?.contentMode = .scaleAspectFit
            IconImage?.backgroundColor = .white
            
            // Label setup
//            symptomLabel?.textAlignment = .center
//            symptomLabel?.numberOfLines = 2
//            symptomLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            //symptomLabel?.textColor = .gray // Gray color
        }
    
    func configure(with symptom: SymptomItem, isSelected: Bool) {
        guard let iconImage = IconImage, let label = symptomLabel else {
                print("ERROR in configure: IBOutlets are nil!")
                return
            }
            
            label.text = symptom.name
            iconImage.image = UIImage(named: symptom.icon)
            
            updateSelectionState(isSelected)
                
        }
    
    private func updateSelectionState(_ isSelected: Bool) {
        if isSelected {
                    contentView.backgroundColor = UIColor.systemGray3
                    symptomLabel.textColor = .white
                } else {
                    contentView.backgroundColor = .clear
                    symptomLabel.textColor = .gray
                }
        }
    //Added this to ensure state is reset when cell is reused
        override func prepareForReuse() {
            super.prepareForReuse()
            contentView.backgroundColor = .clear
            symptomLabel.textColor = .gray
            IconImage.tintColor = .gray
        }

}
