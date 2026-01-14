//
//  ExploreRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ExploreRoutinesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var exploreRoutineImage: UIImageView!
    @IBOutlet weak var exploreRoutineTitle: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var EstTimeOutlet: UILabel!
    @IBOutlet weak var timeTagContainer: UIView!
    @IBOutlet weak var RoutineDescriptionOutlet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
   

    func configureCell(_ routine: Routine) {
        
        exploreRoutineTitle.text = routine.name
        RoutineDescriptionOutlet.text=routine.routineTagline
        if let imageName = routine.thumbnailImageName {
            exploreRoutineImage.image = UIImage(named: imageName)
            
        } else {
            exploreRoutineImage.image = UIImage(systemName: "dumbbell.fill")
        }
        
        timeTagContainer.layer.cornerRadius = timeTagContainer.frame.height / 2
        exploreRoutineTitle.textColor = .label
//      exploreRoutineImage.contentMode = .scaleAspectFill
        exploreRoutineImage.clipsToBounds = true
        cellBackgroundView.backgroundColor = .systemBackground
        cellBackgroundView.layer.cornerRadius = 16
        exploreRoutineImage.layer.cornerRadius = 16
        
    }


    
    
    
    
}
