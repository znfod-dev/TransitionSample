//
//  CardCell.swift
//  TrasitionSample
//
//  Created by ParkJonghyun on 2020/09/28.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cellBackground: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    func setupCell(imgViewName: String) {
        imgView.image = UIImage(named: imgViewName)
    }
    
    func setupView() {
        
        self.cellBackground.layer.borderWidth = 0.0
        self.cellBackground.layer.borderColor = UIColor.clear.cgColor
        self.cellBackground.layer.cornerRadius = 10
        self.cellBackground.layer.masksToBounds = false
        
        
    }
}
