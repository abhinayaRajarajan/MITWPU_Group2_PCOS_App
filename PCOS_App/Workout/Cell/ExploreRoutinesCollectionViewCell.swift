//
//  ExploreRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ExploreRoutinesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plusButton: UIButton!

    var onCreateRoutineTapped: (() -> Void)?
    
    
    @IBOutlet weak var exploreRoutineImage: UIImageView!
    @IBOutlet weak var exploreRoutineTitle: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.layer.cornerRadius = 20
        cellBackgroundView.layer.masksToBounds = true
        exploreRoutineTitle.numberOfLines = 2
                exploreRoutineTitle.textAlignment = .center
                exploreRoutineTitle.font = .systemFont(ofSize: 14, weight: .medium)
    }
//    func configure(title:String,image:UIImage){
//        exploreRoutineTitle.text=title
//        exploreRoutineImage.image=image
//    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        onCreateRoutineTapped?()   // call the callback
    }

    
    
    func configureCreateRoutine() {
        plusButton.isHidden = false        // SHOW PLUS BUTTON
        exploreRoutineImage.isHidden = true  // hide the static image if needed
        exploreRoutineTitle.text = "Create your own\ncustom routine"
        exploreRoutineTitle.textColor = .systemGray3
        exploreRoutineImage.image = UIImage(systemName: "plus.circle.fill")
        exploreRoutineImage.tintColor = .systemGray3
        cellBackgroundView.backgroundColor = .systemGray6
    }

    func configureRoutine(_ routine: Routine) {
        plusButton.isHidden = true         // HIDE PLUS BUTTON
        exploreRoutineImage.isHidden = false
        
        exploreRoutineTitle.text = routine.name

        if let imageName = routine.thumbnailImageName {
            exploreRoutineImage.image = UIImage(named: imageName)
        } else {
            exploreRoutineImage.image = UIImage(named: "routine_placeholder")
        }

        exploreRoutineTitle.textColor = .label
        exploreRoutineImage.contentMode = .scaleAspectFit
        cellBackgroundView.backgroundColor = .systemGray6
    }


    
    
    
    
}
