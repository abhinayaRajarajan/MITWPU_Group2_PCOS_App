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
    
    @IBOutlet weak var symptomTag: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var tableContentView: UIView!
    @IBOutlet weak var sugarLevelLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    // Static identifier for easy reuse
    static let identifier = "InsulinFoodTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "InsulinFoodTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        tableContentView.layer.cornerRadius = 20
        tableContentView.backgroundColor = .white
        
        symptomTag.layer.cornerRadius = 10
        
        foodImage.layer.cornerRadius = 20
        foodImage.clipsToBounds = true
        foodImage.contentMode = .scaleAspectFill
        foodImage.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
    }
    
    // configure cell with food data
    func configure(with food: CellFoodItem) {
        foodNameLabel.text = food.name
        sugarLevelLabel.text = "\(food.sugarContent) Sugar"
        dayLabel.text = "\(food.day)"
        
        // If using emoji as image
        if food.image.count <= 2 {
            //emoji
            let label = UILabel(frame: foodImage.bounds)
            label.text = food.image
            label.font = .systemFont(ofSize: 40)
            label.textAlignment = .center
            foodImage.addSubview(label)
        } else {
            //image
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

