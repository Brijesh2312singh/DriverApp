import UIKit
import Alamofire

class UserAcceptedOfferVC: UIViewController {
    
    var offerId: Int = 0
    var rideId: Int = 0
    var offeredPrice: Double = 0
    var dropLat: Double = 0
    var dropLng: Double = 0

    var pickupAddress = ""
    var dropAddress = ""
    var passengerName = ""
    var passengerPhone = ""
    var pickupLat: Double = 0
    var pickupLng: Double = 0
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    var fare: String = ""
    let titleLbl = UILabel()
    let priceLbl = UILabel()
    let routeCard = UIView()
    let passengerCard = UIView()
    let acceptBtn = UIButton()
    let declineBtn = UIButton()
    
    
    var driverLat: Double = 0
    var driverLng: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        setupHeader()
        setupSuccessView()
        setupPassengerCard()
        setupRouteCard()
        setupButtons()
    }
    
    func setupHeader() {
        let backBtn = UIButton(frame: CGRect(x: 18, y: 55, width: 42, height: 42))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let navTitle = UILabel(frame: CGRect(x: 70, y: 58, width: view.frame.width - 140, height: 32))
        navTitle.text = "Confirm Ride"
        navTitle.textAlignment = .center
        navTitle.font = .boldSystemFont(ofSize: 18)
        view.addSubview(navTitle)
    }
    
    func setupSuccessView() {
        let iconView = UIView(frame: CGRect(x: (view.frame.width - 80) / 2, y: 130, width: 80, height: 80))
        iconView.backgroundColor = .systemGreen
        iconView.layer.cornerRadius = 40
        view.addSubview(iconView)
        
        let check = UIImageView(frame: CGRect(x: 22, y: 22, width: 36, height: 36))
        check.image = UIImage(systemName: "checkmark")
        check.tintColor = .white
        check.contentMode = .scaleAspectFit
        iconView.addSubview(check)
        
        titleLbl.frame = CGRect(x: 25, y: 230, width: view.frame.width - 50, height: 50)
        titleLbl.text = "User has accepted your offer"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 22)
        titleLbl.numberOfLines = 2
        view.addSubview(titleLbl)
        
        priceLbl.frame = CGRect(x: 25, y: 290, width: view.frame.width - 50, height: 54)
        priceLbl.text = "₹\(Int(offeredPrice))"
        priceLbl.textAlignment = .center
        priceLbl.font = .boldSystemFont(ofSize: 42)
        priceLbl.textColor = .systemGreen
        view.addSubview(priceLbl)
    }
    
    func setupPassengerCard() {
        passengerCard.frame = CGRect(x: 24, y: 365, width: view.frame.width - 48, height: 90)
        passengerCard.backgroundColor = UIColor.systemGray6
        passengerCard.layer.cornerRadius = 18
        view.addSubview(passengerCard)
        
        let nameLbl = UILabel(frame: CGRect(x: 18, y: 16, width: passengerCard.frame.width - 36, height: 24))
        nameLbl.text = passengerName.isEmpty ? "Passenger" : passengerName
        nameLbl.font = .boldSystemFont(ofSize: 17)
        passengerCard.addSubview(nameLbl)
        
        let phoneLbl = UILabel(frame: CGRect(x: 18, y: 48, width: passengerCard.frame.width - 36, height: 22))
        phoneLbl.text = passengerPhone.isEmpty ? "Phone not available" : passengerPhone
        phoneLbl.font = .systemFont(ofSize: 14)
        phoneLbl.textColor = .darkGray
        passengerCard.addSubview(phoneLbl)
    }
    
    func setupRouteCard() {
        routeCard.frame = CGRect(x: 24, y: 475, width: view.frame.width - 48, height: 135)
        routeCard.backgroundColor = .white
        routeCard.layer.cornerRadius = 18
        routeCard.layer.borderWidth = 1
        routeCard.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(routeCard)
        
        let pickupDot = UIView(frame: CGRect(x: 18, y: 32, width: 10, height: 10))
        pickupDot.backgroundColor = .systemGreen
        pickupDot.layer.cornerRadius = 5
        routeCard.addSubview(pickupDot)
        
        let pickupLbl = UILabel(frame: CGRect(x: 40, y: 24, width: routeCard.frame.width - 60, height: 28))
        pickupLbl.text = pickupAddress
        pickupLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(pickupLbl)
        
        let line = UIView(frame: CGRect(x: 22, y: 52, width: 2, height: 28))
        line.backgroundColor = UIColor.systemGray4
        routeCard.addSubview(line)
        
        let dropDot = UIView(frame: CGRect(x: 18, y: 88, width: 10, height: 10))
        dropDot.backgroundColor = .systemRed
        dropDot.layer.cornerRadius = 5
        routeCard.addSubview(dropDot)
        
        let dropLbl = UILabel(frame: CGRect(x: 40, y: 80, width: routeCard.frame.width - 60, height: 28))
        dropLbl.text = dropAddress
        dropLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(dropLbl)
    }
    
    func setupButtons() {
        let bottomY = view.frame.height - 110
        let buttonWidth = (view.frame.width - 60) / 2
        
        declineBtn.frame = CGRect(x: 20, y: bottomY, width: buttonWidth, height: 56)
        declineBtn.setTitle("Decline", for: .normal)
        declineBtn.backgroundColor = .white
        declineBtn.setTitleColor(.black, for: .normal)
        declineBtn.layer.cornerRadius = 15
        declineBtn.layer.borderWidth = 1
        declineBtn.layer.borderColor = UIColor.systemGray4.cgColor
        declineBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        declineBtn.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        view.addSubview(declineBtn)
        
        acceptBtn.frame = CGRect(x: declineBtn.frame.maxX + 20, y: bottomY, width: buttonWidth, height: 56)
        acceptBtn.setTitle("Accept Ride", for: .normal)
        acceptBtn.backgroundColor = UIColor.systemIndigo
        acceptBtn.setTitleColor(.white, for: .normal)
        acceptBtn.layer.cornerRadius = 15
        acceptBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        acceptBtn.addTarget(self, action: #selector(finalAcceptTapped), for: .touchUpInside)
        view.addSubview(acceptBtn)
    }
    
    @objc func finalAcceptTapped() {
        
        if offerId == 0 {
            showAlert("Offer id missing")
            return
        }
        
        let params: [String: Any] = [
            "offer_id": offerId
        ]
        
        print("FINAL ACCEPT PARAMS:", params)
        
        acceptBtn.isEnabled = false
        acceptBtn.setTitle("Accepting...", for: .normal)
        
        AF.request(
            "\(baseURL)/rides/driver-final-accept",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            DispatchQueue.main.async {
                self.acceptBtn.isEnabled = true
                self.acceptBtn.setTitle("Accept Ride", for: .normal)
            }
            
            print("FINAL ACCEPT STATUS:", response.response?.statusCode ?? 0)
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("FINAL ACCEPT RAW:", raw)
                
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    if let success = json?["success"] as? Bool, success == true {
                        let price = (json?["offered_price"] as? Double) ?? (Double("\(json?["offered_price"] ?? "")") ?? self.offeredPrice)
                        DispatchQueue.main.async {
                            let vc = PassengerDetailsVC()

                            vc.rideId = self.rideId
                            vc.passengerName = self.passengerName
                            vc.passengerPhone = self.passengerPhone
                            vc.pickupAddress = self.pickupAddress
                            vc.dropAddress = self.dropAddress

                            vc.pickupLat = self.pickupLat
                            vc.pickupLng = self.pickupLng

                            vc.dropLat = self.dropLat
                            vc.dropLng = self.dropLng

                            vc.fare = String(format: "%.2f", self.offeredPrice)
                            vc.offerId = self.offerId
                            vc.offeredPrice = price
                            vc.driverLat = self.driverLat
                            vc.driverLng = self.driverLng
                            vc.paymentMethod = "Cash"

                            print("PASS TO PASSENGER PICKUP:", self.pickupLat, self.pickupLng)
                            print("PASS TO PASSENGER DROP:", self.dropLat, self.dropLng)

                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.showAlert(json?["message"] as? String ?? "Final accept failed")
                    }
                    
                } catch {
                    self.showAlert("Invalid response")
                }
                
            case .failure(let error):
                self.showAlert(error.localizedDescription)
            }
        }
    }
    
    @objc func declineTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Alert",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

