//
//  PushedViewController.swift
//  TrasitionSample
//
//  Created by ParkJonghyun on 2020/09/28.
//

import UIKit

class PushedViewController: UIViewController {
    
    @IBOutlet weak var imageBottle: UIImageView!
    @IBOutlet weak var topBackground: UIView!
    @IBOutlet weak var bottomBackground: UIView!
    
    var selectedImage: String?
    
    var topHexColor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if let topColor = topHexColor {
            topBackground.backgroundColor =  topColor.hexColor
        }
        if let imageToLoad = selectedImage {
            imageBottle.image  = UIImage(named: imageToLoad)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTap))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissTap() {
        self.navigationController?.popViewController(animated: true)
    }


}

// MARK: - Protocol for Transition
extension PushedViewController : AnimTransitionable
{
    var cellImageView: UIImageView {
        return imageBottle
    }
    
    var backgroundColor: UIView {
        return topBackground
    }
    
    var cellBackground: UIView {
        return bottomBackground
    }
    
}


