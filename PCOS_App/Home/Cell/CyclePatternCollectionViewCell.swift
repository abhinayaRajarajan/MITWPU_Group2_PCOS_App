//
//  CyclePatternCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class CyclePatternCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cyclePatternView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cyclePatternView.layer.cornerRadius = cyclePatternView.frame.height / 2
    }

}
