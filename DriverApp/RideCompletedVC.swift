//
//  RideCompletedVC.swift
//  DriverApp
//

import UIKit

class RideCompletedVC: UIViewController {
    
    var fare: String = ""
    var paymentMethod: String = ""
    var passengerName: String = ""
    var pickupAddress: String = ""
    var dropAddress: String = ""
    
    let fareLbl = UILabel()
    let paymentLbl = UILabel()
    let completeBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 145))
        headerView.backgroundColor = .systemGreen
        view.addSubview(headerView)
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .white
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Ride Completed"
        titleLbl.textColor = .white
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 16)
        headerView.addSubview(titleLbl)
        
        let checkTop = UIImageView(frame: CGRect(x: view.frame.width - 50, y: 58, width: 28, height: 28))
        checkTop.image = UIImage(systemName: "checkmark.circle")
        checkTop.tintColor = .white
        headerView.addSubview(checkTop)
        
        let cardView = UIView(frame: CGRect(x: 14, y: 115, width: view.frame.width - 28, height: view.frame.height - 140))
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10
        view.addSubview(cardView)
        
        let buildingImg = UIImageView(frame: CGRect(x: 55, y: 40, width: cardView.frame.width - 110, height: 130))
        buildingImg.image = UIImage(systemName: "building.2.fill")
        buildingImg.tintColor = UIColor.systemGray5
        buildingImg.contentMode = .scaleAspectFit
        cardView.addSubview(buildingImg)
        
        let bigCheckView = UIView(frame: CGRect(x: (cardView.frame.width - 70) / 2, y: 70, width: 70, height: 70))
        bigCheckView.backgroundColor = .systemGreen
        bigCheckView.layer.cornerRadius = 35
        cardView.addSubview(bigCheckView)
        
        let bigCheck = UIImageView(frame: CGRect(x: 18, y: 18, width: 34, height: 34))
        bigCheck.image = UIImage(systemName: "checkmark")
        bigCheck.tintColor = .white
        bigCheckView.addSubview(bigCheck)
        
        let msgLbl = UILabel(frame: CGRect(x: 35, y: 185, width: cardView.frame.width - 70, height: 50))
        msgLbl.text = "Ride has been completed\nsuccessfully"
        msgLbl.numberOfLines = 2
        msgLbl.textAlignment = .center
        msgLbl.font = .boldSystemFont(ofSize: 16)
        cardView.addSubview(msgLbl)
        
        let line1 = UIView(frame: CGRect(x: 25, y: 270, width: cardView.frame.width - 50, height: 1))
        line1.backgroundColor = UIColor.systemGray5
        cardView.addSubview(line1)
        
        let fareTitle = UILabel(frame: CGRect(x: 0, y: 300, width: cardView.frame.width, height: 20))
        fareTitle.text = "Total Fare"
        fareTitle.textAlignment = .center
        fareTitle.font = .boldSystemFont(ofSize: 13)
        cardView.addSubview(fareTitle)
        
        fareLbl.frame = CGRect(x: 0, y: 325, width: cardView.frame.width, height: 36)
        fareLbl.textAlignment = .center
        fareLbl.font = .boldSystemFont(ofSize: 28)
        cardView.addSubview(fareLbl)
        
        let line2 = UIView(frame: CGRect(x: 25, y: 390, width: cardView.frame.width - 50, height: 1))
        line2.backgroundColor = UIColor.systemGray5
        cardView.addSubview(line2)
        
        let paymentTitle = UILabel(frame: CGRect(x: 0, y: 420, width: cardView.frame.width, height: 20))
        paymentTitle.text = "Payment Method"
        paymentTitle.textAlignment = .center
        paymentTitle.font = .systemFont(ofSize: 13)
        paymentTitle.textColor = .darkGray
        cardView.addSubview(paymentTitle)
        
        paymentLbl.frame = CGRect(x: 0, y: 445, width: cardView.frame.width, height: 28)
        paymentLbl.textAlignment = .center
        paymentLbl.font = .boldSystemFont(ofSize: 16)
        cardView.addSubview(paymentLbl)
        
        completeBtn.frame = CGRect(x: 22, y: cardView.frame.height - 80, width: cardView.frame.width - 44, height: 52)
        completeBtn.backgroundColor = .systemGreen
        completeBtn.setTitle("Complete Ride", for: .normal)
        completeBtn.setTitleColor(.white, for: .normal)
        completeBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        completeBtn.layer.cornerRadius = 10
        completeBtn.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        cardView.addSubview(completeBtn)
    }
    
    func setData() {
        fareLbl.text = fare.isEmpty ? "₹0" : "₹\(fare)"
        paymentLbl.text = paymentMethod.isEmpty ? "Cash" : paymentMethod
    }
    
    @objc func completeTapped() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "EarningsVC"
        ) as? EarningsVC else {
            print("EarningsVC not found")
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
