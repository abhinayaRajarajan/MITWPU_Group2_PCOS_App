//
//  HomeHeaderCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class HomeHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var gradientOverlayView: UIView!
    
    @IBOutlet weak var quoteLabel: UILabel!
    
    @IBOutlet weak var logPeriodButton: UIButton!
    
    
    private let gradientLayer = CAGradientLayer()
    
        override func awakeFromNib() {
            super.awakeFromNib()
            setup()
            setupMultiStopGradient()
        }

        private func setup() {
            headerImageView.image = UIImage(named: "home_img")
            headerImageView.contentMode = .scaleToFill
            headerImageView.clipsToBounds = true
            
            logPeriodButton.layer.cornerRadius = logPeriodButton.frame.height / 2
            logPeriodButton.tintColor = UIColor(hex: "#FE7A96")
            
            
        }
    private func setupMultiStopGradient() {
            // The color you want to blend into
            let blendColor = UIColor(hex: "#FCEEED")
        gradientOverlayView.backgroundColor = .clear
            
            gradientLayer.colors = [
                UIColor.clear.cgColor,                // 0% Top: Pure image
                UIColor.clear.cgColor,                // 60% Middle: Still pure image
                blendColor.withAlphaComponent(0.4).cgColor, // 80% Start: Soft transition
                blendColor.cgColor,                   // 95%: Solid color
                blendColor.cgColor                    // 100% Bottom: Solid color
            ]
            
            // top 75% of your image crystal clear
            gradientLayer.locations = [0.0, 0.75, 0.85, 1.0]
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            if gradientLayer.superlayer == nil {
                headerImageView.layer.addSublayer(gradientLayer)
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = headerImageView.bounds
        }



}
