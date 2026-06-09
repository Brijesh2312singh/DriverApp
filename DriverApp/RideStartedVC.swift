//
//  RideStartedVC.swift
//  DriverApp
//

import UIKit
import Alamofire

class RideStartedVC: UIViewController {
    
    var rideId: Int = 0

    var passengerName: String = ""
    var passengerPhone: String = ""

    var pickupAddress: String = ""
    var dropAddress: String = ""

    var fare: String = ""
    var distance: String = ""

    var dropLat: Double = 0
    var dropLng: Double = 0
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let nameLbl = UILabel()
    let pickupLbl = UILabel()
    let dropLbl = UILabel()
    let fareLbl = UILabel()
    let distanceLbl = UILabel()
    let completeBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        headerView.backgroundColor = .systemGreen
        view.addSubview(headerView)
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .white
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: 30))
        titleLbl.text = "Ride Started"
        titleLbl.textAlignment = .center
        titleLbl.textColor = .white
        titleLbl.font = .boldSystemFont(ofSize: 16)
        headerView.addSubview(titleLbl)
        
        let check = UIImageView(frame: CGRect(x: view.frame.width - 50, y: 58, width: 28, height: 28))
        check.image = UIImage(systemName: "checkmark.circle")
        check.tintColor = .white
        headerView.addSubview(check)
        
        let card = UIView(frame: CGRect(x: 14, y: 120, width: view.frame.width - 28, height: view.frame.height - 145))
        card.backgroundColor = .white
        card.layer.cornerRadius = 22
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        view.addSubview(card)
        
        let profile = UIImageView(frame: CGRect(x: 20, y: 28, width: 64, height: 64))
        profile.image = UIImage(systemName: "person.circle.fill")
        profile.tintColor = .darkGray
        profile.contentMode = .scaleAspectFill
        profile.layer.cornerRadius = 32
        profile.clipsToBounds = true
        card.addSubview(profile)
        
        nameLbl.frame = CGRect(x: 100, y: 35, width: 220, height: 24)
        nameLbl.font = .boldSystemFont(ofSize: 17)
        card.addSubview(nameLbl)
        
        let ratingLbl = UILabel(frame: CGRect(x: 100, y: 62, width: 80, height: 20))
        ratingLbl.text = "4.8 ★"
        ratingLbl.textColor = .orange
        ratingLbl.font = .boldSystemFont(ofSize: 14)
        card.addSubview(ratingLbl)
        
        let line1 = UIView(frame: CGRect(x: 20, y: 110, width: card.frame.width - 40, height: 1))
        line1.backgroundColor = UIColor.systemGray5
        card.addSubview(line1)
        
        let greenDot = UIView(frame: CGRect(x: 30, y: 145, width: 9, height: 9))
        greenDot.backgroundColor = .systemGreen
        greenDot.layer.cornerRadius = 4.5
        card.addSubview(greenDot)
        
        pickupLbl.frame = CGRect(x: 55, y: 137, width: card.frame.width - 80, height: 24)
        pickupLbl.font = .boldSystemFont(ofSize: 14)
        card.addSubview(pickupLbl)
        
        let redDot = UIView(frame: CGRect(x: 30, y: 205, width: 9, height: 9))
        redDot.backgroundColor = .systemRed
        redDot.layer.cornerRadius = 4.5
        card.addSubview(redDot)
        
        dropLbl.frame = CGRect(x: 55, y: 197, width: card.frame.width - 80, height: 24)
        dropLbl.font = .boldSystemFont(ofSize: 14)
        card.addSubview(dropLbl)
        
        let verticalLine = UIView(frame: CGRect(x: 34, y: 154, width: 1, height: 50))
        verticalLine.backgroundColor = UIColor.systemGray4
        card.addSubview(verticalLine)
        
        let line2 = UIView(frame: CGRect(x: 20, y: 250, width: card.frame.width - 40, height: 1))
        line2.backgroundColor = UIColor.systemGray5
        card.addSubview(line2)
        
        let fareTitle = UILabel(frame: CGRect(x: 25, y: 285, width: 120, height: 18))
        fareTitle.text = "Fare"
        fareTitle.textColor = .gray
        fareTitle.font = .systemFont(ofSize: 13)
        card.addSubview(fareTitle)
        
        fareLbl.frame = CGRect(x: 25, y: 310, width: 120, height: 32)
        fareLbl.font = .boldSystemFont(ofSize: 22)
        card.addSubview(fareLbl)
        
        let divider = UIView(frame: CGRect(x: card.frame.width / 2, y: 280, width: 1, height: 75))
        divider.backgroundColor = UIColor.systemGray5
        card.addSubview(divider)
        
        let distanceTitle = UILabel(frame: CGRect(x: card.frame.width / 2 + 30, y: 285, width: 120, height: 18))
        distanceTitle.text = "Distance"
        distanceTitle.textColor = .gray
        distanceTitle.font = .systemFont(ofSize: 13)
        card.addSubview(distanceTitle)
        
        distanceLbl.frame = CGRect(x: card.frame.width / 2 + 30, y: 310, width: 140, height: 32)
        distanceLbl.font = .boldSystemFont(ofSize: 22)
        card.addSubview(distanceLbl)
        
        completeBtn.frame = CGRect(x: 20, y: card.frame.height - 80, width: card.frame.width - 40, height: 52)
        completeBtn.backgroundColor = .systemGreen
        completeBtn.setTitle("Complete Ride", for: .normal)
        completeBtn.setTitleColor(.white, for: .normal)
        completeBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        completeBtn.layer.cornerRadius = 10
        completeBtn.addTarget(self, action: #selector(completeRideTapped), for: .touchUpInside)
        card.addSubview(completeBtn)
    }
    
    func setData() {
        nameLbl.text = passengerName.isEmpty ? "Passenger" : passengerName
        pickupLbl.text = pickupAddress
        dropLbl.text = dropAddress
        fareLbl.text = "₹\(fare)"
        distanceLbl.text = distance.isEmpty ? "0 km" : distance
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    @objc func completeRideTapped() {

        let params: [String: Any] = [
            "ride_id": rideId
        ]

        AF.request(
            "\(baseURL)/rides/complete",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("COMPLETE RAW:", raw)
            }

            print("COMPLETE STATUS:", response.response?.statusCode ?? 0)

            DispatchQueue.main.async {

                if response.response?.statusCode == 200 {

                    let vc = LiveRideVC()
                    vc.rideId = self.rideId
                    vc.passengerName = self.passengerName
                    vc.passengerPhone = self.passengerPhone
                    vc.dropAddress = self.dropAddress
                    vc.dropLat = self.dropLat
                    vc.dropLng = self.dropLng
                    vc.fare = self.fare
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
