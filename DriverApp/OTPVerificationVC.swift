//
//  OTPVerificationVC.swift
//  DriverApp
//

import UIKit
import Alamofire
import CoreLocation
class OTPVerificationVC: UIViewController {
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let otpStack = UIStackView()
    var otpLabels: [UILabel] = []
    var otpText = ""
    
    let infoLbl = UILabel()
    let resendLbl = UILabel()
    let startRideBtn = UIButton()
    var rideId: Int = 0
    var passengerName: String = ""
    var passengerPhone: String = ""
    var pickupAddress: String = ""
    var dropAddress: String = ""
    var fare: String = ""
    var distance: String = ""
    var dropLat: Double = 0
    var dropLng: Double = 0
    var pickupLat: Double = 0
    var pickupLng: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Verify Ride OTP"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 16)
        view.addSubview(titleLbl)
        
        let shieldView = UIImageView(frame: CGRect(x: (view.frame.width - 74) / 2, y: 115, width: 74, height: 74))
        shieldView.image = UIImage(systemName: "lock.shield.fill")
        shieldView.tintColor = .systemGreen
        shieldView.contentMode = .scaleAspectFit
        view.addSubview(shieldView)
        
        infoLbl.frame = CGRect(x: 35, y: 205, width: view.frame.width - 70, height: 40)
        infoLbl.text = "Ask customer for the OTP\nto start the ride"
        infoLbl.textAlignment = .center
        infoLbl.numberOfLines = 2
        infoLbl.font = .systemFont(ofSize: 14)
        infoLbl.textColor = .darkGray
        view.addSubview(infoLbl)
        
        otpStack.frame = CGRect(x: 35, y: 270, width: view.frame.width - 70, height: 58)
        otpStack.axis = .horizontal
        otpStack.distribution = .fillEqually
        otpStack.spacing = 12
        view.addSubview(otpStack)
        
        for _ in 0..<4 {
            let lbl = UILabel()
            lbl.text = ""
            lbl.textAlignment = .center
            lbl.font = .boldSystemFont(ofSize: 24)
            lbl.layer.cornerRadius = 8
            lbl.layer.borderWidth = 1
            lbl.layer.borderColor = UIColor.systemGray4.cgColor
            lbl.clipsToBounds = true
            otpStack.addArrangedSubview(lbl)
            otpLabels.append(lbl)
        }
        
        resendLbl.frame = CGRect(x: 35, y: 350, width: view.frame.width - 70, height: 24)
        resendLbl.text = "Didn't get OTP? Resend (00:30)"
        resendLbl.textAlignment = .center
        resendLbl.font = .systemFont(ofSize: 13)
        resendLbl.textColor = .systemGreen
        view.addSubview(resendLbl)
        
        setupKeypad()
    }
    
    func setupKeypad() {
        let startY: CGFloat = 405
        let buttonW = view.frame.width / 3
        let buttonH: CGFloat = 58
        
        let nums = ["1","2","3","4","5","6","7","8","9","","0","⌫"]
        
        for i in 0..<12 {
            let row = i / 3
            let col = i % 3
            
            let btn = UIButton(frame: CGRect(
                x: CGFloat(col) * buttonW,
                y: startY + CGFloat(row) * buttonH,
                width: buttonW,
                height: buttonH
            ))
            
            btn.setTitle(nums[i], for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
            btn.backgroundColor = .white
            
            if nums[i] == "" {
                btn.isEnabled = false
            } else {
                btn.addTarget(self, action: #selector(keypadTapped(_:)), for: .touchUpInside)
            }
            
            view.addSubview(btn)
            
            let line = UIView(frame: CGRect(x: btn.frame.minX, y: btn.frame.minY, width: btn.frame.width, height: 1))
            line.backgroundColor = UIColor.systemGray5
            view.addSubview(line)
        }
        
        startRideBtn.frame = CGRect(x: 24, y: view.frame.height - 80, width: view.frame.width - 48, height: 52)
        startRideBtn.backgroundColor = .systemGreen
        startRideBtn.setTitle("Start Ride", for: .normal)
        startRideBtn.setTitleColor(.white, for: .normal)
        startRideBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        startRideBtn.layer.cornerRadius = 10
        startRideBtn.addTarget(self, action: #selector(startRideTapped), for: .touchUpInside)
        view.addSubview(startRideBtn)
    }
    
    @objc func keypadTapped(_ sender: UIButton) {
        guard let value = sender.titleLabel?.text else { return }
        
        if value == "⌫" {
            if !otpText.isEmpty {
                otpText.removeLast()
            }
        } else {
            if otpText.count < 4 {
                otpText.append(value)
            }
        }
        
        updateOTPUI()
    }
    
    func updateOTPUI() {
        for i in 0..<4 {
            if i < otpText.count {
                let index = otpText.index(otpText.startIndex, offsetBy: i)
                otpLabels[i].text = String(otpText[index])
            } else {
                otpLabels[i].text = ""
            }
        }
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    func runOnMain(_ block: @escaping () -> Void) {
        Foundation.DispatchQueue.main.async {
            block()
        }
    }

    @objc func startRideTapped() {
        
        if otpText.count != 4 {
            print("Enter 4 digit OTP")
            return
        }
        
        let params: [String: Any] = [
            "ride_id": rideId,
            "otp": otpText
        ]
        
        AF.request(
            "\(baseURL)/rides/start",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("START RIDE RAW:", raw)
            }
            
            print("START RIDE STATUS:", response.response?.statusCode ?? 0)
            
            self.runOnMain {
                
                if response.response?.statusCode == 200 {

                    print("========== DISTANCE DEBUG ==========")

                    print("Pickup Address:", self.pickupAddress)
                    print("Pickup Lat:", self.pickupLat)
                    print("Pickup Lng:", self.pickupLng)

                    print("Drop Address:", self.dropAddress)
                    print("Drop Lat:", self.dropLat)
                    print("Drop Lng:", self.dropLng)

                    print("===================================")

                    let pickupLocation = CLLocation(
                        latitude: self.pickupLat,
                        longitude: self.pickupLng
                    )

                    let dropLocation = CLLocation(
                        latitude: self.dropLat,
                        longitude: self.dropLng
                    )

                    let distanceKm = pickupLocation.distance(from: dropLocation) / 1000

                    print("CALCULATED DISTANCE:", distanceKm)

                    let vc = RideStartedVC()
                    vc.rideId = self.rideId
                    vc.passengerName = self.passengerName
                    vc.passengerPhone = self.passengerPhone
                    vc.pickupAddress = self.pickupAddress
                    vc.dropAddress = self.dropAddress
                    vc.fare = self.fare
                    vc.distance = String(format: "%.1f km", distanceKm)
                    vc.dropLat = self.dropLat
                    vc.dropLng = self.dropLng
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

