//
//  PassengerDetailsVC.swift
//  DriverApp
//

import UIKit
import Alamofire

class PassengerDetailsVC: UIViewController {
    
    
    var paymentType: String = "Cash"
  
    
    var rideId: Int = 0
        var passengerName: String = ""
        var passengerPhone: String = ""

        var pickupAddress: String = ""
        var dropAddress: String = ""

        var pickupLat: Double = 0
        var pickupLng: Double = 0
        var dropLat: Double = 0
        var dropLng: Double = 0
    var distance: String = ""
        var fare: String = ""
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let profileImageView = UIImageView()
    let nameLbl = UILabel()
    let ratingLbl = UILabel()
    let pickupLbl = UILabel()
    let dropLbl = UILabel()
    let fareLbl = UILabel()
    let paymentLbl = UILabel()
    let arrivedBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setData()
    }
    
    func setupUI() {
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Passenger Details"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 16)
        view.addSubview(titleLbl)
        
        let line = UIView(frame: CGRect(x: 0, y: 104, width: view.frame.width, height: 1))
        line.backgroundColor = UIColor.systemGray5
        view.addSubview(line)
        
        profileImageView.frame = CGRect(x: 24, y: 130, width: 72, height: 72)
        profileImageView.backgroundColor = UIColor.systemGray5
        profileImageView.layer.cornerRadius = 36
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .darkGray
        profileImageView.contentMode = .scaleAspectFill
        view.addSubview(profileImageView)
        
        nameLbl.frame = CGRect(x: 112, y: 138, width: 220, height: 24)
        nameLbl.font = .boldSystemFont(ofSize: 17)
        view.addSubview(nameLbl)
        
        ratingLbl.frame = CGRect(x: 112, y: 164, width: 120, height: 22)
        ratingLbl.text = "4.8 ★"
        ratingLbl.textColor = .orange
        ratingLbl.font = .boldSystemFont(ofSize: 14)
        view.addSubview(ratingLbl)
        
        let callBtn = circleButton(x: 45, y: 230, icon: "phone.fill")
        callBtn.addTarget(self, action: #selector(callPassenger), for: .touchUpInside)
        view.addSubview(callBtn)
        
        let chatBtn = circleButton(x: (view.frame.width - 52) / 2, y: 230, icon: "message.fill")
        view.addSubview(chatBtn)
        
        let locationBtn = circleButton(x: view.frame.width - 97, y: 230, icon: "location.fill")
        view.addSubview(locationBtn)
        
        let divider = UIView(frame: CGRect(x: 20, y: 310, width: view.frame.width - 40, height: 1))
        divider.backgroundColor = UIColor.systemGray5
        view.addSubview(divider)
        
        addLocationBlock(
            y: 335,
            icon: "mappin",
            title: "Pickup Address",
            valueLabel: pickupLbl
        )
        
        addLocationBlock(
            y: 410,
            icon: "mappin",
            title: "Drop Address",
            valueLabel: dropLbl
        )
        
        let fareTitle = UILabel(frame: CGRect(x: 25, y: 510, width: 120, height: 18))
        fareTitle.text = "Fare"
        fareTitle.textColor = .gray
        fareTitle.font = .systemFont(ofSize: 12)
        view.addSubview(fareTitle)
        
        fareLbl.frame = CGRect(x: 25, y: 530, width: 120, height: 25)
        fareLbl.font = .boldSystemFont(ofSize: 18)
        view.addSubview(fareLbl)
        
        let paymentTitle = UILabel(frame: CGRect(x: view.frame.width / 2, y: 510, width: 120, height: 18))
        paymentTitle.text = "Payment"
        paymentTitle.textColor = .gray
        paymentTitle.font = .systemFont(ofSize: 12)
        view.addSubview(paymentTitle)
        
        paymentLbl.frame = CGRect(x: view.frame.width / 2, y: 530, width: 120, height: 25)
        paymentLbl.font = .boldSystemFont(ofSize: 17)
        view.addSubview(paymentLbl)
        
        arrivedBtn.frame = CGRect(x: 20, y: view.frame.height - 90, width: view.frame.width - 40, height: 52)
        arrivedBtn.backgroundColor = .systemGreen
        arrivedBtn.setTitle("I've Arrived", for: .normal)
        arrivedBtn.setTitleColor(.white, for: .normal)
        arrivedBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        arrivedBtn.layer.cornerRadius = 10
        arrivedBtn.addTarget(self, action: #selector(arrivedTapped), for: .touchUpInside)
        view.addSubview(arrivedBtn)
    }
    
    func setData() {
        nameLbl.text = passengerName
        pickupLbl.text = pickupAddress
        dropLbl.text = dropAddress
        fareLbl.text = "₹\(fare)"
        paymentLbl.text = paymentType
    }
    
    func circleButton(x: CGFloat, y: CGFloat, icon: String) -> UIButton {
        let btn = UIButton(frame: CGRect(x: x, y: y, width: 52, height: 52))
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 26
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray5.cgColor
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .systemGreen
        return btn
    }
    
    func addLocationBlock(y: CGFloat, icon: String, title: String, valueLabel: UILabel) {
        let iconView = UIImageView(frame: CGRect(x: 25, y: y + 7, width: 16, height: 16))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .black
        view.addSubview(iconView)
        
        let titleLbl = UILabel(frame: CGRect(x: 50, y: y, width: 250, height: 18))
        titleLbl.text = title
        titleLbl.textColor = .gray
        titleLbl.font = .systemFont(ofSize: 12)
        view.addSubview(titleLbl)
        
        valueLabel.frame = CGRect(x: 50, y: y + 20, width: view.frame.width - 75, height: 24)
        valueLabel.font = .boldSystemFont(ofSize: 14)
        valueLabel.numberOfLines = 2
        view.addSubview(valueLabel)
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    @objc func arrivedTapped() {
        let params: [String: Any] = [
            "ride_id": rideId
        ]
        
        AF.request(
            "\(baseURL)/rides/arrived",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("ARRIVED RAW:", raw)
            }
            
            print("ARRIVED STATUS:", response.response?.statusCode ?? 0)
            
            DispatchQueue.main.async {
                
                let vc = NavigateToPickupVC()

                vc.rideId = self.rideId

                vc.pickupAddress = self.pickupAddress
                vc.pickupLat = self.pickupLat
                vc.pickupLng = self.pickupLng

                vc.dropAddress = self.dropAddress
                vc.dropLat = self.dropLat
                vc.dropLng = self.dropLng

                vc.passengerName = self.passengerName
                vc.passengerPhone = self.passengerPhone

                vc.fare = self.fare
                vc.distance = self.distance

                self.navigationController?.pushViewController(vc, animated: true)
            
                
                print("Go to OTP Screen")
            }
        }
    }
    
    @objc func callPassenger() {
        guard !passengerPhone.isEmpty,
              let url = URL(string: "tel://\(passengerPhone)") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
