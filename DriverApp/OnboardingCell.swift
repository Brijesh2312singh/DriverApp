//
//  OnboardingCell.swift
//  DriverApp
//
//  Created by Coding Brains on 05/06/26.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    let identifier = String(describing: OnboardingCell.self)
    @IBOutlet weak var slideimageView: UIImageView!
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideTitleDescriptionLbl: UILabel!
    func setup(_ slide: OnboardingSlide) {
        slideimageView.image = slide.image
        slideTitleLbl.text = slide.title
        slideTitleDescriptionLbl.text = slide.description
    }
    
    }
    
    
    

