import UIKit
import Alamofire

class RideOfferVC: UIViewController {
    
    var rideId: Int = 0
    var pickupAddress = ""
    var dropAddress = ""
    var passengerName = ""
    var passengerPhone = ""
    var userFare: Double = 80
    var userMaxFare: Double = 100
    var driverId: Int = 0
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    var driverLat: Double = 0
    var driverLng: Double = 0
    let scrollView = UIScrollView()
    let contentView = UIView()
    var fare: String = ""
    let titleLbl = UILabel()
    let routeCard = UIView()
    let fareCard = UIView()
    let customPriceTF = UITextField()
    let sendOfferBtn = UIButton()
    
    var selectedPrice: Double = 0
    var priceButtons: [UIButton] = []
    var pickupLat: Double = 0
    var pickupLng: Double = 0
    var dropLat: Double = 0
    var dropLng: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }
    
    func setupUI() {
        setupScroll()
        setupHeader()
        setupRouteCard()
        setupFareCard()
        setupOfferSection()
        setupSendButton()
    }
    
    func setupScroll() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height + 80)
        scrollView.addSubview(contentView)
    }
    
    func setupHeader() {
        titleLbl.frame = CGRect(x: 40, y: 50, width: view.frame.width - 120, height: 32)
        titleLbl.text = "Ride Details"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLbl)
    }
    
    func setupRouteCard() {
        routeCard.frame = CGRect(x: 20, y: 115, width: view.frame.width - 40, height: 120)
        routeCard.backgroundColor = .white
        routeCard.layer.cornerRadius = 18
        routeCard.layer.shadowColor = UIColor.black.cgColor
        routeCard.layer.shadowOpacity = 0.08
        routeCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        routeCard.layer.shadowRadius = 10
        contentView.addSubview(routeCard)
        
        let pickupDot = UIView(frame: CGRect(x: 18, y: 28, width: 10, height: 10))
        pickupDot.backgroundColor = .systemGreen
        pickupDot.layer.cornerRadius = 5
        routeCard.addSubview(pickupDot)
        
        let pickupLbl = UILabel(frame: CGRect(x: 40, y: 20, width: routeCard.frame.width - 60, height: 28))
        pickupLbl.text = pickupAddress
        pickupLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(pickupLbl)
        
        let line = UIView(frame: CGRect(x: 22, y: 44, width: 2, height: 28))
        line.backgroundColor = UIColor.systemGray4
        routeCard.addSubview(line)
        
        let dropDot = UIView(frame: CGRect(x: 18, y: 78, width: 10, height: 10))
        dropDot.backgroundColor = .systemRed
        dropDot.layer.cornerRadius = 5
        routeCard.addSubview(dropDot)
        
        let dropLbl = UILabel(frame: CGRect(x: 40, y: 70, width: routeCard.frame.width - 60, height: 28))
        dropLbl.text = dropAddress
        dropLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(dropLbl)
    }
    
    func setupFareCard() {
        fareCard.frame = CGRect(x: 20, y: 255, width: view.frame.width - 40, height: 105)
        fareCard.backgroundColor = UIColor.systemGray6
        fareCard.layer.cornerRadius = 18
        contentView.addSubview(fareCard)
        
        let userTitle = UILabel(frame: CGRect(x: 18, y: 18, width: 130, height: 22))
        userTitle.text = "User Fare"
        userTitle.font = .systemFont(ofSize: 14)
        userTitle.textColor = .darkGray
        fareCard.addSubview(userTitle)
        
        let userFareLbl = UILabel(frame: CGRect(x: 18, y: 42, width: 130, height: 34))
        userFareLbl.text = "₹\(Int(userFare))"
        userFareLbl.font = .boldSystemFont(ofSize: 28)
        userFareLbl.textColor = .systemGreen
        fareCard.addSubview(userFareLbl)
        
        let maxTitle = UILabel(frame: CGRect(x: fareCard.frame.width - 150, y: 18, width: 130, height: 22))
        maxTitle.text = "Max Budget"
        maxTitle.font = .systemFont(ofSize: 14)
        maxTitle.textColor = .darkGray
        maxTitle.textAlignment = .right
        fareCard.addSubview(maxTitle)
        
        let maxFareLbl = UILabel(frame: CGRect(x: fareCard.frame.width - 150, y: 42, width: 130, height: 34))
        maxFareLbl.text = "₹\(Int(userMaxFare))"
        maxFareLbl.font = .boldSystemFont(ofSize: 28)
        maxFareLbl.textColor = .systemGreen
        maxFareLbl.textAlignment = .right
        fareCard.addSubview(maxFareLbl)
    }
    
    func setupOfferSection() {
        let offerTitle = UILabel(frame: CGRect(x: 20, y: 390, width: view.frame.width - 40, height: 24))
        offerTitle.text = "Your Offer"
        offerTitle.font = .boldSystemFont(ofSize: 18)
        contentView.addSubview(offerTitle)
        
        let hintLbl = UILabel(frame: CGRect(x: 20, y: 418, width: view.frame.width - 40, height: 22))
        hintLbl.text = "Offer higher than user fare"
        hintLbl.font = .systemFont(ofSize: 13)
        hintLbl.textColor = .gray
        contentView.addSubview(hintLbl)
        
        let prices = suggestedPrices()
        let buttonWidth: CGFloat = (view.frame.width - 70) / 4
        
        for (index, price) in prices.enumerated() {
            let x = 20 + CGFloat(index) * (buttonWidth + 10)
            
            let btn = UIButton(frame: CGRect(x: x, y: 458, width: buttonWidth, height: 48))
            btn.setTitle("₹\(Int(price))", for: .normal)
            btn.backgroundColor = index == 0 ? UIColor.systemIndigo : UIColor.white
            btn.setTitleColor(index == 0 ? .white : .black, for: .normal)
            btn.layer.cornerRadius = 12
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
            btn.tag = Int(price)
            btn.addTarget(self, action: #selector(priceButtonTapped(_:)), for: .touchUpInside)
            contentView.addSubview(btn)
            priceButtons.append(btn)
            
            if index == 0 {
                selectedPrice = price
            }
        }
        
        let customTitle = UILabel(frame: CGRect(x: 20, y: 535, width: view.frame.width - 40, height: 22))
        customTitle.text = "Custom Price"
        customTitle.font = .systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(customTitle)
        
        customPriceTF.frame = CGRect(x: 20, y: 565, width: view.frame.width - 40, height: 54)
        customPriceTF.placeholder = "Enter amount"
        customPriceTF.keyboardType = .numberPad
        customPriceTF.backgroundColor = .white
        customPriceTF.layer.cornerRadius = 12
        customPriceTF.layer.borderWidth = 1
        customPriceTF.layer.borderColor = UIColor.systemGray4.cgColor
        customPriceTF.leftView = UILabel(frame: CGRect(x: 0, y: 0, width: 38, height: 54))
        customPriceTF.leftViewMode = .always
        if let lbl = customPriceTF.leftView as? UILabel {
            lbl.text = "₹"
            lbl.textAlignment = .center
            lbl.font = .boldSystemFont(ofSize: 18)
        }
        contentView.addSubview(customPriceTF)
    }
    
    func setupSendButton() {
        sendOfferBtn.frame = CGRect(x: 20, y: view.frame.height - 95, width: view.frame.width - 40, height: 56)
        sendOfferBtn.backgroundColor = UIColor.systemIndigo
        sendOfferBtn.setTitle("Send Offer", for: .normal)
        sendOfferBtn.setTitleColor(.white, for: .normal)
        sendOfferBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        sendOfferBtn.layer.cornerRadius = 15
        sendOfferBtn.addTarget(self, action: #selector(sendOfferTapped), for: .touchUpInside)
        view.addSubview(sendOfferBtn)
    }
    
    func suggestedPrices() -> [Double] {
        let values = [
            userFare + 5,
            userFare + 10,
            userFare + 15,
            userFare + 20
        ]
        
        if userMaxFare > 0 {
            return values.filter { $0 > userFare && $0 <= userMaxFare }
        }
        
        return values.filter { $0 > userFare }
    }
    
    @objc func priceButtonTapped(_ sender: UIButton) {
        selectedPrice = Double(sender.tag)
        customPriceTF.text = ""
        
        priceButtons.forEach {
            $0.backgroundColor = .white
            $0.setTitleColor(.black, for: .normal)
        }
        
        sender.backgroundColor = UIColor.systemIndigo
        sender.setTitleColor(.white, for: .normal)
    }
    
    @objc func sendOfferTapped() {
        let customAmount = Double(customPriceTF.text ?? "")
        let amount = customAmount ?? selectedPrice
        
        if amount <= userFare {
            showAlert("Offer price must be greater than user fare")
            return
        }
        
        if userMaxFare > 0 && amount > userMaxFare {
            showAlert("Offer price is higher than user max budget")
            return
        }
        
        sendDriverOfferAPI(price: amount)
    }
    
    func sendDriverOfferAPI(price: Double) {
        let params: [String: Any] = [
            "ride_id": rideId,
            "offered_price": price
        ]
        
        sendOfferBtn.isEnabled = false
        sendOfferBtn.setTitle("Sending...", for: .normal)
        
        AF.request(
            "\(baseURL)/rides/driver-offer",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            DispatchQueue.main.async {
                self.sendOfferBtn.isEnabled = true
                self.sendOfferBtn.setTitle("Send Offer", for: .normal)
            }
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("DRIVER OFFER RAW:", raw)
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    if let success = json?["success"] as? Bool, success == true,
                       let offer = json?["offer"] as? [String: Any] {
                        
                        let offerId = offer["id"] as? Int ?? 0
                        
                        DispatchQueue.main.async {
                            let vc = OfferWaitingVC()
                            vc.rideId = self.rideId
                            vc.offerId = offerId
                            vc.offeredPrice = price
                            vc.pickupAddress = self.pickupAddress
                            vc.dropAddress = self.dropAddress
                            vc.driverId = self.driverId
                            vc.passengerName = self.passengerName
                            vc.passengerPhone = self.passengerPhone
                            vc.pickupLat = self.pickupLat
                            vc.pickupLng = self.pickupLng
                            vc.dropLat = self.dropLat
                            vc.dropLng = self.dropLng
                            vc.driverLat = self.driverLat
                            vc.driverLng = self.driverLng
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    } else {
                        self.showAlert(json?["message"] as? String ?? "Offer failed")
                    }
                    
                } catch {
                    self.showAlert("Invalid response")
                }
                
            case .failure(let error):
                self.showAlert(error.localizedDescription)
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
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
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
