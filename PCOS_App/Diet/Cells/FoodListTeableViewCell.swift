//
//  FoodListTeableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class FoodListTeableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var foodNamleLabel: UILabel!
    
    // MARK: - Lifecycle
     override func awakeFromNib() {
         super.awakeFromNib()
         setupUI()
     }
     
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
         
         // Visual feedback when selected
         UIView.animate(withDuration: 0.1) {
             self.containerView.backgroundColor = selected ? UIColor.systemGray6 : .white
         }
     }
     
     override func prepareForReuse() {
         super.prepareForReuse()
         foodNamleLabel.text = nil
         containerView.backgroundColor = .white
     }
     
     // MARK: - Setup
     private func setupUI() {
         selectionStyle = .none
         backgroundColor = .clear
         contentView.backgroundColor = .clear
         
         // Configure container view
         containerView.backgroundColor = .white
         containerView.layer.cornerRadius = 12
         containerView.layer.borderWidth = 1
         containerView.layer.borderColor = UIColor.systemGray5.cgColor
         
         // Add subtle shadow
         containerView.layer.shadowColor = UIColor.black.cgColor
         containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
         containerView.layer.shadowOpacity = 0.05
         containerView.layer.shadowRadius = 2
         containerView.layer.masksToBounds = false
         
         // Configure food name label
         foodNamleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
         foodNamleLabel.textColor = .label
         
         // Configure the built-in accessory view (disclosure indicator)
         accessoryType = .disclosureIndicator
     }
     
     // MARK: - Configuration
     func configure(with foodItem: InsulinFoodItem) {
         foodNamleLabel.text = foodItem.name
     }
 }
