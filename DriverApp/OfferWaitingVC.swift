import UIKit
import SocketIO

class OfferWaitingVC: UIViewController {
    
    var rideId: Int = 0
    var offerId: Int = 0
    var offeredPrice: Double = 0
    var pickupAddress = ""
    var dropAddress = ""
    var driverId: Int = 0
    var passengerName = ""
    var passengerPhone = ""
    let socketURL = "https://unarmored-dropper-blatantly.ngrok-free.dev"
    var driverLat: Double = 0
    var driverLng: Double = 0
    var socketManager: SocketManager?
    var socket: SocketIOClient?
    var fare: String = ""
    let iconView = UIView()
    let checkImage = UIImageView()
    let titleLbl = UILabel()
    let priceCard = UIView()
    let priceTitleLbl = UILabel()
    let priceLbl = UILabel()
    let routeCard = UIView()
    let pickupLbl = UILabel()
    let dropLbl = UILabel()
    let activity = UIActivityIndicatorView(style: .large)
    let waitingLbl = UILabel()
    let backBtn = UIButton()
    var dropLat: Double = 0
    var dropLng: Double = 0
    var pickupLat: Double = 0
    var pickupLng: Double = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Joining Driver Room:", self.driverId)
        setupUI()
        connectSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socket?.disconnect()
    }
    
    func setupUI() {
        
        let greenBg = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 290))
        greenBg.backgroundColor = UIColor.systemGreen
        view.addSubview(greenBg)
        
        let topBackBtn = UIButton(frame: CGRect(x: 18, y: 55, width: 42, height: 42))
        topBackBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        topBackBtn.tintColor = .white
        topBackBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(topBackBtn)
        
        iconView.frame = CGRect(x: (view.frame.width - 70) / 2, y: 100, width: 70, height: 70)
        iconView.backgroundColor = .white
        iconView.layer.cornerRadius = 35
        view.addSubview(iconView)
        
        checkImage.frame = CGRect(x: 18, y: 18, width: 34, height: 34)
        checkImage.image = UIImage(systemName: "checkmark")
        checkImage.tintColor = .systemGreen
        iconView.addSubview(checkImage)
        
        titleLbl.frame = CGRect(x: 20, y: 185, width: view.frame.width - 40, height: 60)
        titleLbl.text = "Offer sent!\nWaiting for user response"
        titleLbl.font = .boldSystemFont(ofSize: 22)
        titleLbl.textColor = .white
        titleLbl.numberOfLines = 2
        titleLbl.textAlignment = .center
        view.addSubview(titleLbl)
        
        setupPriceCard()
        setupRouteCard()
        setupBottom()
    }
    
    func setupPriceCard() {
        priceCard.frame = CGRect(x: 24, y: 250, width: view.frame.width - 48, height: 150)
        priceCard.backgroundColor = .white
        priceCard.layer.cornerRadius = 20
        priceCard.layer.shadowColor = UIColor.black.cgColor
        priceCard.layer.shadowOpacity = 0.12
        priceCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        priceCard.layer.shadowRadius = 12
        view.addSubview(priceCard)
        
        priceTitleLbl.frame = CGRect(x: 0, y: 28, width: priceCard.frame.width, height: 24)
        priceTitleLbl.text = "Offered Price"
        priceTitleLbl.textAlignment = .center
        priceTitleLbl.font = .systemFont(ofSize: 15)
        priceTitleLbl.textColor = .darkGray
        priceCard.addSubview(priceTitleLbl)
        
        priceLbl.frame = CGRect(x: 0, y: 58, width: priceCard.frame.width, height: 52)
        priceLbl.text = "₹\(Int(offeredPrice))"
        priceLbl.textAlignment = .center
        priceLbl.font = .boldSystemFont(ofSize: 38)
        priceLbl.textColor = .systemGreen
        priceCard.addSubview(priceLbl)
    }
    
    func setupRouteCard() {
        routeCard.frame = CGRect(x: 24, y: 425, width: view.frame.width - 48, height: 130)
        routeCard.backgroundColor = UIColor.systemGray6
        routeCard.layer.cornerRadius = 18
        view.addSubview(routeCard)
        
        let pickupDot = UIView(frame: CGRect(x: 18, y: 30, width: 10, height: 10))
        pickupDot.backgroundColor = .systemGreen
        pickupDot.layer.cornerRadius = 5
        routeCard.addSubview(pickupDot)
        
        pickupLbl.frame = CGRect(x: 40, y: 22, width: routeCard.frame.width - 60, height: 28)
        pickupLbl.text = pickupAddress
        pickupLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(pickupLbl)
        
        let line = UIView(frame: CGRect(x: 22, y: 48, width: 2, height: 28))
        line.backgroundColor = UIColor.systemGray4
        routeCard.addSubview(line)
        
        let dropDot = UIView(frame: CGRect(x: 18, y: 84, width: 10, height: 10))
        dropDot.backgroundColor = .systemRed
        dropDot.layer.cornerRadius = 5
        routeCard.addSubview(dropDot)
        
        dropLbl.frame = CGRect(x: 40, y: 76, width: routeCard.frame.width - 60, height: 28)
        dropLbl.text = dropAddress
        dropLbl.font = .systemFont(ofSize: 15, weight: .medium)
        routeCard.addSubview(dropLbl)
    }
    
    func setupBottom() {
        activity.center = CGPoint(x: view.center.x, y: 625)
        activity.color = .systemGreen
        activity.startAnimating()
        view.addSubview(activity)
        
        waitingLbl.frame = CGRect(x: 35, y: 660, width: view.frame.width - 70, height: 50)
        waitingLbl.text = "Your offer has been sent to the user.\nPlease wait for confirmation."
        waitingLbl.numberOfLines = 2
        waitingLbl.font = .systemFont(ofSize: 15)
        waitingLbl.textColor = .darkGray
        waitingLbl.textAlignment = .center
        view.addSubview(waitingLbl)
        
        backBtn.frame = CGRect(x: 24, y: view.frame.height - 105, width: view.frame.width - 48, height: 56)
        backBtn.backgroundColor = UIColor.systemIndigo
        backBtn.setTitle("Back to Home", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        backBtn.layer.cornerRadius = 16
        backBtn.addTarget(self, action: #selector(backHomeTapped), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    
    func connectSocket() {
        socketManager = SocketManager(
            socketURL: URL(string: socketURL)!,
            config: [
                .log(true),
                .compress,
                .forceWebsockets(true)
            ]
        )
        
        socket = socketManager?.defaultSocket
        
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self else { return }
            
            print("✅ OfferWaiting Socket Connected")
            print("Joining Driver Room:", self.driverId)
            
            self.socket?.emit("joinDriver", self.driverId)
        }
        
        socket?.on("offerAccepted") { [weak self] data, ack in
            guard let self = self else { return }
            
            print("✅ OFFER ACCEPTED RECEIVED:", data)
            
            guard let offerData = data.first as? [String: Any] else {
                print("Invalid offer accepted data")
                return
            }
            
            let offerId = offerData["offer_id"] as? Int ?? self.offerId
            let rideId = offerData["ride_id"] as? Int ?? self.rideId
            let price = Double("\(offerData["offered_price"] ?? self.offeredPrice)") ?? self.offeredPrice
            
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Offer Accepted 🎉",
                    message: "User accepted your offer ₹\(Int(price)).\nDo you want to accept this ride?",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Decline", style: .destructive) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                
                alert.addAction(UIAlertAction(title: "Accept Ride", style: .default) { _ in
                    let vc = UserAcceptedOfferVC()
                    vc.offerId = offerId
                    vc.rideId = rideId
                    vc.offeredPrice = price
                    vc.pickupAddress = self.pickupAddress
                    vc.dropAddress = self.dropAddress
                    vc.passengerName = self.passengerName
                    vc.passengerPhone = self.passengerPhone
                    vc.pickupLat = self.pickupLat
                    vc.pickupLng = self.pickupLng
                    vc.dropLat = self.dropLat
                    vc.dropLng = self.dropLng
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
                self.present(alert, animated: true)
            }
        }
        
        socket?.connect()
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backHomeTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
