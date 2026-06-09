//
//  OnboardingVC.swift
//  DriverApp
//
//  Created by Coding Brains on 05/06/26.
//

import UIKit

class OnboardingVC: UIViewController {
    @IBOutlet weak var nextBTN: UIButton!
    @IBOutlet weak var onboardingCollectiopnView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    var slides: [OnboardingSlide] = []
    let indicatorStack = UIStackView()
        var indicators: [UIView] = []

    var currentPage = 0 {
        didSet {
            updateIndicator()
            if currentPage == slides.count - 1 {
                nextBTN.setTitle("Get Started", for: .normal)
            } else {
                nextBTN.setTitle("Next", for: .normal)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingCollectiopnView.delegate = self
        onboardingCollectiopnView.dataSource = self
        
        nextBTN.layer.cornerRadius = 10
        
        slides = [
            OnboardingSlide(
                title: "Drive Anytime, Earn Anytime",
                description: "Join thousands of drivers and start earning on your own schedule.",
                image: #imageLiteral(resourceName: "Image1"),
            ),
            OnboardingSlide(
                title: "Smart Navigation,More Rides",
                description: "Get real-time directions and find the best routes to your passengers.",
                image: #imageLiteral(resourceName: "Image2"),
                
            ),
            OnboardingSlide(
                title: "Secure Earnings,Every Time",
                description: "Fast payments, weekly payouts and 100% secure transactions.",
                image: #imageLiteral(resourceName: "Image3"),
            ),
            OnboardingSlide(
                title: "Track & Grow Your Performance",
                description: "Monitor your earnings, ratings and performance in real time.",
                image: #imageLiteral(resourceName: "Image4"),
            ),
            OnboardingSlide(
                title: "Happy Riders, Better Ratings",
                description: "Great service leads to happy riders and better earnings for you.",
                image: #imageLiteral(resourceName: "Image5"),
                
            )
        ]
        pageController.isHidden = true
                setupCustomIndicator()
        
        
    }
    func setupCustomIndicator() {

           indicatorStack.axis = .horizontal
           indicatorStack.spacing = 8
           indicatorStack.alignment = .center
           indicatorStack.distribution = .fill
           indicatorStack.translatesAutoresizingMaskIntoConstraints = false

           view.addSubview(indicatorStack)

           NSLayoutConstraint.activate([
               indicatorStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               indicatorStack.bottomAnchor.constraint(equalTo: nextBTN.topAnchor, constant: 25),
               indicatorStack.heightAnchor.constraint(equalToConstant: 10)
           ])

           for i in 0..<slides.count {
               let view = UIView()
               view.backgroundColor = i == 0 ? .systemGreen : .systemGray4
               view.layer.cornerRadius = 4
               view.translatesAutoresizingMaskIntoConstraints = false

               view.widthAnchor.constraint(equalToConstant: i == 0 ? 28 : 8).isActive = true
               view.heightAnchor.constraint(equalToConstant: 8).isActive = true

               indicators.append(view)
               indicatorStack.addArrangedSubview(view)
           }
       }
    func updateIndicator() {

            for (index, indicator) in indicators.enumerated() {

                for constraint in indicator.constraints {
                    if constraint.firstAttribute == .width {
                        indicator.removeConstraint(constraint)
                    }
                }

                let width: CGFloat = index == currentPage ? 28 : 8

                indicator.widthAnchor.constraint(equalToConstant: width).isActive = true

                UIView.animate(withDuration: 0.25) {
                    indicator.backgroundColor = index == self.currentPage ? .systemGreen : .systemGray4
                    self.indicatorStack.layoutIfNeeded()
                }
            }
        }
    @IBAction func nextTappedBtn(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
                    UserDefaults.standard.set(true, forKey: "onboardingSeen")

            let vc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "StartVC") as! StartVC

                navigationController?.pushViewController(vc, animated: true)
                    return
                }

                currentPage += 1

                onboardingCollectiopnView.scrollToItem(
                    at: IndexPath(item: currentPage, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
    }
    
    @IBAction func skipBtn(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "onboardingSeen")

        let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "StartVC") as! StartVC

            navigationController?.pushViewController(vc, animated: true)
           }
    }
    

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = onboardingCollectiopnView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        cell.setup(slides[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}

   

