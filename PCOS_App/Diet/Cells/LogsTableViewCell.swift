//
//  LogsTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class LogsTableViewCell: UITableViewCell {

    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var fats: UILabel!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var protein: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodImg: UIImageView!
    
    @IBOutlet weak var innerCell: UIView!
    static var identifier = "LogsTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with log: Food) {
        foodName.text = log.name
        fats.text = "\(Int(log.fatsContent))g"
        carbs.text = "\(Int(log.carbsContent))g"
        protein.text = "\(Int(log.proteinContent))g"
        calories.text = "\(Int(log.calories))kcal"
        foodImg.image = UIImage(named: log.image ?? "biryani")
        innerCell.layer.cornerRadius = 10
        foodImg.clipsToBounds = true
        foodImg.layer.cornerRadius = 10
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.foodImg.image = image
            }
        }.resume()
    }

    
}
