//
//  ViewController.swift
//  TrasitionSample
//
//  Created by ParkJonghyun on 2020/09/28.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var backgroundView: UIView!
    
    var transition = TransitionCoordinator()
    var selectedIndexPath = IndexPath(item: 0, section: 0)
    
    var currentIndexPath = IndexPath(row: 0, section: 0)
    // DataSource for the collection
    var dictionaryDataArray: [[String: String]] =  [
        [
            "imgName": "IMG_1",
            "hexBackgroundColor": "761e30"
        ],
        [
            "imgName": "IMG_2",
            "hexBackgroundColor": "d86940"
        ],
        [
            "imgName": "IMG_3",
            "hexBackgroundColor": "ebb700"
        ],
        [
            "imgName": "IMG_4",
            "hexBackgroundColor": "363538"
        ],

        [
            "imgName": "IMG_5",
            "hexBackgroundColor": "8e5700"
        ],
        [
            "imgName": "IMG_6",
            "hexBackgroundColor": "44485b"
        ]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initCollectionView()
        self.navigationController?.isNavigationBarHidden = true
        self.backgroundView.backgroundColor  =  self.dictionaryDataArray[0]["hexBackgroundColor"]!.hexColor
        
    }
    func initCollectionView() {
        self.collectionView.register(UINib.init(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.collectionViewLayout = AnimationCollectionViewLayout()
    }
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCell
        let imgName = String(format: "IMG_%d", indexPath.row+1)
        let img = UIImage(named: imgName)
        cell.imgView.image = img
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView.cellForItem(at: indexPath) as? CardCell) != nil {
            
            // Reference for the selected Cell
            self.selectedIndexPath = indexPath
            
            let finalVC = PushedViewController()
            finalVC.selectedImage = dictionaryDataArray[indexPath.row]["imgName"]!
            finalVC.topHexColor = dictionaryDataArray[indexPath.row]["hexBackgroundColor"]!
            
            navigationController?.delegate = transition
            
            navigationController?.pushViewController(finalVC, animated: true)
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        if self.currentIndexPath == indexPath {
            return
        }
        self.currentIndexPath = indexPath
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.backgroundColor  =  self.dictionaryDataArray[indexPath.row]["hexBackgroundColor"]!.hexColor
            
        }
    }
}

class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return PushAnimator()
        case .pop:
            return PopAnimator()
        default:
            return nil
        }
        
    }
    
}

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? AnimTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? AnimTransitionable else {
            transitionContext.completeTransition(false)
            return
        }
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        fromViewController.view.backgroundColor = UIColor.clear
        
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let imageViewSnapshot = UIImageView(image: fromVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFit
        
        
        // Background View With Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor
        containerView.addSubview(backgroundView)
        
        
        // Cell Background
        let cellBackground = UIView()
        cellBackground.frame =  containerView.convert(fromVC.cellBackground.frame, from: fromVC.cellBackground.superview)
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        cellBackground.layer.cornerRadius = fromVC.cellBackground.layer.cornerRadius
        cellBackground.layer.masksToBounds = fromVC.cellBackground.layer.masksToBounds
        
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        containerView.addSubview(cellBackground)
        containerView.addSubview(imageViewSnapshot)
        
        fromViewController.view.isHidden = true
        toViewController.view.isHidden = true
        
        
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellImageView.superview)
        
        
        let frameAnim1 = CGRect(x: 0, y: cellBackground.frame.minY, width: UIScreen.main.bounds.width, height: cellBackground.frame.height)
        let frameAnim2 = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 150)
        
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1.3) {
                cellBackground.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }()
        
        let animator2 = {
            UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.9) {
                cellBackground.layer.cornerRadius = 0
                cellBackground.frame = frameAnim1
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1.4) {
                cellBackground.frame = frameAnim2
                imageViewSnapshot.frame = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
            }
        }()
        
        
        animator1.addCompletion { _ in
            
            animator2.startAnimation()
        }
        
        animator2.addCompletion {  _ in
            
            animator3.startAnimation(afterDelay: 0.1)
        }
        
        
        animator3.addCompletion {  _ in
            
            imageViewSnapshot.removeFromSuperview()
            cellBackground.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            
            toViewController.view.isHidden = false
            
            transitionContext.completeTransition(true)
            
            
        }
        
        animator1.startAnimation()
        
    }
}
class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? AnimTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? AnimTransitionable else {
            transitionContext.completeTransition(false)
            return
        }
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        fromViewController.view.backgroundColor = UIColor.clear
        
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let imageViewSnapshot = UIImageView(image: fromVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFit
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellImageView.superview)
        
        
        //Background View Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor
        
        // Cell Background
        let cellBackground = UIView()
        cellBackground.frame =  containerView.convert(fromVC.cellBackground.frame, from: fromVC.cellBackground.superview)
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        
        let cellBackgroundToVC = containerView.convert(toVC.cellBackground.frame, from: toVC.cellBackground.superview)
        let imageViewToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
        
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(cellBackground)
        containerView.addSubview(imageViewSnapshot)
        
        fromViewController.view.isHidden = true
        toViewController.view.isHidden = true
        
        
        
        let frameAnim1 = CGRect(x: fromVC.cellBackground.frame.minX, y: 150 , width: UIScreen.main.bounds.width, height: cellBackgroundToVC.height-150)
        let frameAnim2 = CGRect(x: cellBackgroundToVC.minX, y: cellBackgroundToVC.minY, width: cellBackgroundToVC.width, height: cellBackgroundToVC.height )
        let frameImageToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
        
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                cellBackground.frame = frameAnim1
            }
        }()
        
        let animator2 = {
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                imageViewSnapshot.frame = CGRect(x: frameImageToVC.minX, y: cellBackgroundToVC.minY - (toVC.cellImageView.frame.height / 2) , width: imageViewToVC.width, height: imageViewToVC.height)
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.35, dampingRatio: 0.6) {
                cellBackground.frame = frameAnim2
                cellBackground.layer.cornerRadius = 10
                
                imageViewSnapshot.frame = frameImageToVC
                
            }
        }()
        
        
        // Animations Completion Handler
        animator1.addCompletion {  _ in
            
            animator3.startAnimation()
        }
        
        animator3.addCompletion { _ in
            
            imageViewSnapshot.removeFromSuperview()
            cellBackground.removeFromSuperview()
            
            toViewController.view.isHidden = false
            
            transitionContext.completeTransition(true)
        }
        
        animator1.startAnimation()
        animator2.startAnimation()
        
        
    }
}
protocol AnimTransitionable {
    var cellImageView: UIImageView { get }
    var backgroundColor: UIView { get }
    var cellBackground: UIView { get }
}


// Creates a UIColor from a Hex string.
extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


class AnimationCollectionViewLayout: UICollectionViewFlowLayout {

    // Cell Size for each resolution
     var cellSize = CGSize(
        width: (UIScreen.main.bounds.width * 92) / 100,
        height: (UIScreen.main.bounds.height * 71) / 100
    )
    
    
    var contentInsetLeft: CGFloat = 30.0
    var contentInsetRight: CGFloat = 30.0

    required override init() {
        super.init()

        self.scrollDirection = .horizontal
        self.itemSize = self.cellSize
        self.minimumInteritemSpacing = 20.0
        self.minimumLineSpacing = 20.0
        self.sectionInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        
        if let collectionView = collectionView {
            
            let frameSize = collectionView.bounds.width
            
            // leading & trailing for each cell
            self.contentInsetLeft = frameSize / 2 - self.cellSize.width / 2
            self.contentInsetRight = frameSize / 2 - self.cellSize.width / 2
                        
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
            collectionView.contentInset = UIEdgeInsets(top: 0, left: contentInsetLeft, bottom: 0, right: contentInsetRight)
            
  
        }
    }
 
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
    // This method makes the cell centered
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let width = cellSize.width + self.minimumLineSpacing
        var newOffset: CGPoint = CGPoint.zero
        var offset = proposedContentOffset.x + self.contentInsetLeft
        
        if velocity.x > 0 {
            offset = width * ceil(offset / width)
        } else if velocity.x == 0 {
            offset = width * round(offset / width)
        } else if velocity.x < 0 {
            
            offset = width * floor(offset / width)
        }

        newOffset.x = offset - self.contentInsetLeft
        newOffset.y = proposedContentOffset.y
        
        return newOffset
        
    }

    
    
}


extension ViewController : AnimTransitionable
{
    var cellImageView: UIImageView {
            let cell = collectionView?.cellForItem(at: selectedIndexPath) as! CardCell
            return cell.imgView
    }
    
    var backgroundColor: UIView {
        return backgroundView
    }
    
    var cellBackground: UIView {
            let cell = collectionView?.cellForItem(at: selectedIndexPath) as! CardCell
            return cell.cellBackground
    }
    
}








