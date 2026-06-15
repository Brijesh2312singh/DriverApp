//
//  ArrivedAtPickupVC.swift
//  DriverApp
//

import UIKit
import Alamofire

class ArrivedAtPickupVC: UIViewController {
    var fare: String = ""
    var rideId: Int = 0
    var passengerName: String = ""
    var passengerPhone: String = ""
    var pickupAddress: String = ""
    var dropAddress: String = ""
    var distance: String = ""
    var dropLat: Double = 0
    var dropLng: Double = 0
    var pickupLat: Double = 0
    var pickupLng: Double = 0
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    var offeredPrice: Double = 0
    let profileImageView = UIImageView()
    let nameLbl = UILabel()
    let ratingLbl = UILabel()
    let pickupLbl = UILabel()
    let confirmBtn = UIButton()
    let messageBtn = UIButton()
    var driverLat: Double = 0
    var driverLng: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ARRIVED PASSENGER NAME:", passengerName)
        print("ARRIVED PASSENGER PHONE:", passengerPhone)
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
        titleLbl.text = "Arrived at Pickup"
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
        
        let divider = UIView(frame: CGRect(x: 20, y: 225, width: view.frame.width - 40, height: 1))
        divider.backgroundColor = UIColor.systemGray5
        view.addSubview(divider)
        
        let pinIcon = UIImageView(frame: CGRect(x: 24, y: 255, width: 16, height: 16))
        pinIcon.image = UIImage(systemName: "mappin")
        pinIcon.tintColor = .black
        view.addSubview(pinIcon)
        
        let pickupTitle = UILabel(frame: CGRect(x: 50, y: 248, width: 200, height: 18))
        pickupTitle.text = "Pickup Address"
        pickupTitle.textColor = .gray
        pickupTitle.font = .systemFont(ofSize: 12)
        view.addSubview(pickupTitle)
        
        pickupLbl.frame = CGRect(x: 50, y: 268, width: view.frame.width - 75, height: 42)
        pickupLbl.font = .boldSystemFont(ofSize: 14)
        pickupLbl.numberOfLines = 2
        view.addSubview(pickupLbl)
        
        let divider2 = UIView(frame: CGRect(x: 20, y: 335, width: view.frame.width - 40, height: 1))
        divider2.backgroundColor = UIColor.systemGray5
        view.addSubview(divider2)
        
        let infoLbl = UILabel(frame: CGRect(x: 45, y: 390, width: view.frame.width - 90, height: 60))
        infoLbl.text = "Please confirm that you\nhave arrived at pickup location"
        infoLbl.textAlignment = .center
        infoLbl.numberOfLines = 2
        infoLbl.textColor = .darkGray
        infoLbl.font = .systemFont(ofSize: 14)
        view.addSubview(infoLbl)
        
        confirmBtn.frame = CGRect(x: 22, y: view.frame.height - 155, width: view.frame.width - 44, height: 52)
        confirmBtn.backgroundColor = .systemGreen
        confirmBtn.setTitle("Confirm Arrival", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.addTarget(self, action: #selector(confirmArrivalTapped), for: .touchUpInside)
        view.addSubview(confirmBtn)
        
        messageBtn.frame = CGRect(x: 22, y: view.frame.height - 88, width: view.frame.width - 44, height: 48)
        messageBtn.backgroundColor = .white
        messageBtn.setTitle("  Message Customer", for: .normal)
        messageBtn.setTitleColor(.darkGray, for: .normal)
        messageBtn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        messageBtn.tintColor = .systemGreen
        messageBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        messageBtn.layer.cornerRadius = 10
        messageBtn.layer.borderWidth = 1
        messageBtn.layer.borderColor = UIColor.systemGray5.cgColor
        messageBtn.addTarget(self, action: #selector(messageCustomerTapped), for: .touchUpInside)
        view.addSubview(messageBtn)
    }
    
    func setData() {
        nameLbl.text = passengerName.isEmpty ? "Passenger" : passengerName
        pickupLbl.text = pickupAddress
    }
        func authHeaders() -> HTTPHeaders {
            let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        }
        
        @objc func confirmArrivalTapped() {
            print("Confirm Arrival Ride ID:", rideId)
            
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
                    if response.response?.statusCode == 200 {
                        print("Go to OTP Screen")
                        
                        let vc = OTPVerificationVC()

                        vc.rideId = self.rideId
                        vc.passengerName = self.passengerName
                        vc.passengerPhone = self.passengerPhone
                        vc.pickupAddress = self.pickupAddress
                        vc.dropAddress = self.dropAddress

                        // ✅ fare pass
                        vc.fare = self.fare
                        vc.offeredPrice = self.offeredPrice

                        vc.driverLat = self.driverLat
                        vc.driverLng = self.driverLng
                        vc.dropLat = self.dropLat
                        vc.dropLng = self.dropLng
                        vc.pickupLat = self.pickupLat
                        vc.pickupLng = self.pickupLng

                        print("PASS FARE TO OTP:", self.fare)
                        print("PASS OFFERED PRICE TO OTP:", self.offeredPrice)

                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
    
    @objc func messageCustomerTapped() {
        guard !passengerPhone.isEmpty,
              let url = URL(string: "sms://\(passengerPhone)") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
