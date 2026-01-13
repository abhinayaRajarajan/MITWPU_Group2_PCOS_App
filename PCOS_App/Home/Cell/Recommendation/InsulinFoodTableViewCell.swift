//
//  InsulinFoodTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class InsulinFoodTableViewCell: UITableViewCell {

    // Disambiguate FoodItem if multiple types exist with the same name
    typealias CellFoodItem = PCOS_App.InsulinFoodItem

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var tableContentView: UIView!
    @IBOutlet weak var sugarLevelLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var acneview: UIView!
    
    
    // Static identifier for easy reuse
        static let identifier = "InsulinFoodTableViewCell"
        
        // For loading from nib
        static func nib() -> UINib {
            return UINib(nibName: "InsulinFoodTableViewCell", bundle: nil)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            //acneview.layer.cornerRadius = 20
            
            // Cell styling
            selectionStyle = .none
            backgroundColor = .clear
            
            // Content view styling
            tableContentView.layer.cornerRadius = 20
            tableContentView.backgroundColor = .white
            tableContentView.layer.shadowColor = UIColor.black.cgColor
            tableContentView.layer.shadowOpacity = 0.05
            tableContentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            tableContentView.layer.shadowRadius = 4
            
            // Image styling
            foodImage.layer.cornerRadius = 20
            foodImage.clipsToBounds = true
            foodImage.contentMode = .scaleAspectFill
            foodImage.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
            
            // Label styling
//            foodNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
//            foodNameLabel.textColor = .black
            
//            sugarLevelLabel.font = .systemFont(ofSize: 14, weight: .medium)
//            sugarLevelLabel.textColor = .systemRed
//            
//            caloriesLabel.font = .systemFont(ofSize: 14, weight: .regular)
//            caloriesLabel.textColor = .gray
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            // Configure the view for the selected state
        }
        
        // Configure cell with food data
        func configure(with food: CellFoodItem) {
            foodNameLabel.text = food.name
            sugarLevelLabel.text = "\(food.sugarContent) Sugar"
            dayLabel.text = "\(food.day)"
            
            // If using emoji as image
            if food.image.count <= 2 {
                // It's an emoji
                let label = UILabel(frame: foodImage.bounds)
                label.text = food.image
                label.font = .systemFont(ofSize: 40)
                label.textAlignment = .center
                foodImage.addSubview(label)
            } else {
                // It's an image name
                foodImage.image = UIImage(named: food.image)
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            // Clear emoji label if exists
            foodImage.subviews.forEach { $0.removeFromSuperview() }
            foodImage.image = nil
        }
    }

