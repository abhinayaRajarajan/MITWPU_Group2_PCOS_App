//
//  FirstCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class GoalCards: UICollectionViewCell {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var done: UILabel!
    @IBOutlet weak var toBeDone: UILabel!
    @IBOutlet weak var cardName: UILabel!
//    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(_ model: Card){
        cardName.text = model.name
  //      imageView.image = UIImage(systemName: model.image)
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        //card.layer.borderWidth = 1
        //card.layer.borderColor = UIColor.systemGray5.cgColor
        card.backgroundColor = .systemBackground
        done.text = "\(Int(model.done ?? 0))"
        toBeDone.text = "/\(Int(model.toBeDone))" + (model.unit ?? "")
       // progressView.setProgress(to: Float(CGFloat(model.done ?? 0) / CGFloat(model.toBeDone)))
        // Progress calculation
            let progress = model.toBeDone > 0
        ? min(model.done! / model.toBeDone, 1.0)
                : 0

            progressView.setProgress(Float(progress), animated: true)

            // Optional polish
        progressView.progressTintColor = model.tintColor
            progressView.trackTintColor = .systemGray5
        
    }
    
    
}
