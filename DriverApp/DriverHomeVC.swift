//
//  DriverHomeVC.swift
//  DriverApp
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SocketIO

struct DriverProfileResponse: Codable, Sendable {
    let success: Bool
    let driver: DriverProfile
}

struct DriverProfile: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let car_name: String
    let car_number: String
    let car_color: String
    let is_available: Int
}

struct AvailabilityResponse: Codable, Sendable {
    let success: Bool
    let message: String
    let is_available: Int
}

struct LocationResponse: Codable, Sendable {
    let success: Bool
    let message: String
}

class DriverHomeVC: UIViewController {
    
    let mapView = GMSMapView()
    
    let menuBtn = UIButton()
    let notificationBtn = UIButton()
    
    let statusView = UIView()
    let statusDot = UIView()
    let statusLbl = UILabel()
    
    let bottomCard = UIView()
    let titleLbl = UILabel()
    let subtitleLbl = UILabel()
    let carImageView = UIImageView()
    let goOnlineBtn = UIButton()
    
    let locationManager = CLLocationManager()
    
    var isOnline = false
    var currentLat: Double = 0
    var currentLng: Double = 0
    var driverName = ""
    var carName = ""
    var locationTimer: Timer?
    var isAvailabilityLoading = false
    
    var driverId: Int = 0
    var socketManager: SocketManager?
    var socket: SocketIOClient?

    var passengerName = ""
    var passengerPhone = ""
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    let socketURL = "https://unarmored-dropper-blatantly.ngrok-free.dev"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupMap()
        setupTopBar()
        setupBottomCard()
        updateOnlineUI()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        getDriverProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLocationUpdates()
        socket?.disconnect()
    }
    
    func setupMap() {
        mapView.frame = view.bounds
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
    }
    
    func setupTopBar() {
        menuBtn.frame = CGRect(x: 22, y: 60, width: 42, height: 42)
        menuBtn.backgroundColor = .white
        menuBtn.layer.cornerRadius = 21
        menuBtn.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        menuBtn.tintColor = .black
        view.addSubview(menuBtn)
        
        notificationBtn.frame = CGRect(x: view.frame.width - 64, y: 60, width: 42, height: 42)
        notificationBtn.backgroundColor = .white
        notificationBtn.layer.cornerRadius = 21
        notificationBtn.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        notificationBtn.tintColor = .black
        view.addSubview(notificationBtn)
        
        statusView.frame = CGRect(x: (view.frame.width - 105) / 2, y: 64, width: 105, height: 34)
        statusView.backgroundColor = UIColor.systemGray6
        statusView.layer.cornerRadius = 17
        view.addSubview(statusView)
        
        statusDot.frame = CGRect(x: 14, y: 13, width: 8, height: 8)
        statusDot.layer.cornerRadius = 4
        statusView.addSubview(statusDot)
        
        statusLbl.frame = CGRect(x: 30, y: 0, width: 70, height: 34)
        statusLbl.font = .boldSystemFont(ofSize: 13)
        statusLbl.textAlignment = .left
        statusView.addSubview(statusLbl)
    }
    
    func setupBottomCard() {

        let tabBarHeight: CGFloat = 86
        let safeBottom = view.safeAreaInsets.bottom

        bottomCard.frame = CGRect(
            x: 18,
            y: view.frame.height - tabBarHeight - safeBottom - 210 - 12,
            width: view.frame.width - 36,
            height: 210
        )

        bottomCard.backgroundColor = .white
        bottomCard.layer.cornerRadius = 22
        bottomCard.layer.shadowColor = UIColor.black.cgColor
        bottomCard.layer.shadowOpacity = 0.15
        bottomCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        bottomCard.layer.shadowRadius = 12

        view.addSubview(bottomCard)
    
        
        titleLbl.frame = CGRect(x: 20, y: 22, width: bottomCard.frame.width - 40, height: 24)
        titleLbl.font = .boldSystemFont(ofSize: 18)
        bottomCard.addSubview(titleLbl)
        
        subtitleLbl.frame = CGRect(x: 20, y: 52, width: 210, height: 42)
        subtitleLbl.numberOfLines = 2
        subtitleLbl.textColor = .darkGray
        subtitleLbl.font = .systemFont(ofSize: 14)
        bottomCard.addSubview(subtitleLbl)
        
        carImageView.frame = CGRect(x: bottomCard.frame.width - 120, y: 55, width: 95, height: 70)
        carImageView.image = UIImage(named: "driver_car")
        carImageView.contentMode = .scaleAspectFit
        bottomCard.addSubview(carImageView)
        
        goOnlineBtn.frame = CGRect(x: 18, y: bottomCard.frame.height - 68, width: bottomCard.frame.width - 36, height: 52)
        goOnlineBtn.layer.cornerRadius = 12
        goOnlineBtn.setTitleColor(.white, for: .normal)
        goOnlineBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        goOnlineBtn.addTarget(self, action: #selector(goOnlineTapped), for: .touchUpInside)
        bottomCard.addSubview(goOnlineBtn)
    }
    
    func updateOnlineUI() {
        goOnlineBtn.isEnabled = !isAvailabilityLoading
        goOnlineBtn.alpha = isAvailabilityLoading ? 0.6 : 1.0
        
        if isOnline {
            statusLbl.text = "Online"
            statusDot.backgroundColor = .systemGreen
            titleLbl.text = "You are online"
            subtitleLbl.text = "Waiting for new ride requests"
            goOnlineBtn.backgroundColor = .systemRed
            goOnlineBtn.setTitle(isAvailabilityLoading ? "Please wait..." : "Go Offline", for: .normal)
        } else {
            statusLbl.text = "Offline"
            statusDot.backgroundColor = .systemGray3
            titleLbl.text = "You are offline"
            subtitleLbl.text = "Go online to start receiving\nride requests"
            goOnlineBtn.backgroundColor = .systemGreen
            goOnlineBtn.setTitle(isAvailabilityLoading ? "Please wait..." : "Go Online", for: .normal)
        }
    }
    
    @objc func goOnlineTapped() {
        if isAvailabilityLoading { return }
        let newStatus = isOnline ? 0 : 1
        updateAvailabilityAPI(isAvailable: newStatus)
    }
}

// MARK: - Socket

extension DriverHomeVC {
    
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
            
            print("✅ Socket Connected")
            print("Joining Driver Room:", self.driverId)
            
            self.socket?.emit("joinDriver", self.driverId)
        }
        
        socket?.on("newRide") { [weak self] data, ack in
            
            guard let self = self else { return }
            
            print("🔥 NEW RIDE RECEIVED:", data)
            
            DispatchQueue.main.async {
                self.showRidePopup(data: data)
            }
        }
        
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("❌ Socket Disconnected")
        }
        
        socket?.connect()
    }
    
    func showRidePopup(data: [Any]) {
        
        print("SHOW POPUP CALLED:", data)
        
        guard let rideData = data.first as? [String: Any] else {
            print("Invalid ride data")
            return
        }
        
        let rideId = rideData["ride_id"] as? Int ?? 0
        let pickup = rideData["pickup_address"] as? String ?? "Pickup"
        let drop = rideData["drop_address"] as? String ?? "Drop"
        let price = rideData["price"] ?? 0
        
        let alert = UIAlertController(
            title: "New Ride Request 🚕",
            message: "Ride ID: \(rideId)\nPickup: \(pickup)\nDrop: \(drop)\nPrice: ₹\(price)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive) { _ in
            self.rejectRideAPI(rideId: rideId)
        })
        
        alert.addAction(UIAlertAction(title: "Accept Same Price", style: .default) { _ in
            
            self.acceptRideAPI(rideId: rideId)
            
            let vc = PassengerDetailsVC()
            vc.rideId = rideId
            
            vc.passengerName = rideData["user_name"] as? String ?? ""
            vc.passengerPhone = rideData["user_phone"] as? String ?? ""
            
            vc.pickupAddress = pickup
            vc.dropAddress = drop
            
            vc.pickupLat = Double("\(rideData["pickup_lat"] ?? "0")") ?? 0
            vc.pickupLng = Double("\(rideData["pickup_lng"] ?? "0")") ?? 0
            
            vc.dropLat = Double("\(rideData["drop_lat"] ?? "0")") ?? 0
            vc.dropLng = Double("\(rideData["drop_lng"] ?? "0")") ?? 0
            
            vc.fare = "\(price)"
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Send Higher Offer", style: .default) { _ in
            
            let vc = RideOfferVC()
            vc.fare = "\(price)"
            vc.rideId = rideId
            vc.driverId = self.driverId
            vc.pickupAddress = pickup
            vc.dropAddress = drop
            vc.userFare = Double("\(price)") ?? 0
            vc.userMaxFare = Double("\(rideData["max_price"] ?? 0)") ?? 0
            vc.passengerName = rideData["user_name"] as? String ?? ""
            vc.passengerPhone = "\(rideData["user_phone"] ?? "")"

            vc.pickupLat = Double("\(rideData["pickup_lat"] ?? "0")") ?? 0
            vc.pickupLng = Double("\(rideData["pickup_lng"] ?? "0")") ?? 0
            vc.dropLat = Double("\(rideData["drop_lat"] ?? "0")") ?? 0
            vc.dropLng = Double("\(rideData["drop_lng"] ?? "0")") ?? 0

            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        DispatchQueue.main.async {
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false) {
                    self.present(alert, animated: true)
                }
            } else {
                self.present(alert, animated: true)
            }
        }
    }
    func rejectRideAPI(rideId: Int) {

        let params: [String: Any] = [
            "ride_id": rideId
        ]

        AF.request(
            "\(baseURL)/rides/reject",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("REJECT RAW:", raw)
            }

            print("REJECT STATUS:",
                  response.response?.statusCode ?? 0)
        }
    }
    func acceptRideAPI(rideId: Int) {
        
        let params: [String: Any] = [
            "ride_id": rideId
        ]
        
        AF.request(
            "\(baseURL)/rides/accept",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("ACCEPT RAW:", raw)
            }
            
            print("ACCEPT STATUS:",
                  response.response?.statusCode ?? 0)
        }
    }
}
// MARK: - Location

extension DriverHomeVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            mapView.isMyLocationEnabled = true
            
            if isOnline {
                startLocationUpdates()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLat = location.coordinate.latitude
        currentLng = location.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(
            withLatitude: currentLat,
            longitude: currentLng,
            zoom: 15
        )
        
        mapView.animate(to: camera)
        
        print("Driver Current Lat:", currentLat)
        print("Driver Current Lng:", currentLng)
        
        if isOnline {
            updateDriverLocationAPI()
        }
        
        manager.stopUpdatingLocation()
    }
}

// MARK: - API

extension DriverHomeVC {
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    func getDriverProfile() {
        AF.request(
            "\(baseURL)/drivers/profile",
            method: .get,
            headers: authHeaders()
        )
        .responseData { response in
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("PROFILE RAW:", raw)
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(DriverProfileResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.driverId = decoded.driver.id
                        self.driverName = decoded.driver.name
                        self.carName = decoded.driver.car_name
                        self.isOnline = decoded.driver.is_available == 1
                        
                        self.updateOnlineUI()
                        self.connectSocket()
                        
                        if self.isOnline {
                            self.startLocationUpdates()
                        } else {
                            self.stopLocationUpdates()
                        }
                    }
                    
                } catch {
                    print("Profile Decode Error:", error)
                }
                
            case .failure(let error):
                print("Profile Error:", error.localizedDescription)
            }
        }
    }
    
    func updateAvailabilityAPI(isAvailable: Int) {
        isAvailabilityLoading = true
        updateOnlineUI()
        
        let params: [String: Any] = [
            "is_available": isAvailable
        ]
        
        AF.request(
            "\(baseURL)/drivers/availability",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            print("AVAILABILITY STATUS:", response.response?.statusCode ?? 0)
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("AVAILABILITY RAW:", raw)
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(AvailabilityResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.isAvailabilityLoading = false
                        self.isOnline = decoded.is_available == 1
                        self.updateOnlineUI()
                        
                        if self.isOnline {
                            self.startLocationUpdates()
                        } else {
                            self.stopLocationUpdates()
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.isAvailabilityLoading = false
                        self.updateOnlineUI()
                    }
                    print("Availability Decode Error:", error)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isAvailabilityLoading = false
                    self.updateOnlineUI()
                }
                print("Availability API Error:", error.localizedDescription)
            }
        }
    }
    
    func updateDriverLocationAPI() {
        let params: [String: Any] = [
            "lat": currentLat,
            "lng": currentLng
        ]
        
        AF.request(
            "\(baseURL)/drivers/update-location",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            print("LOCATION STATUS:", response.response?.statusCode ?? 0)
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("LOCATION RAW:", raw)
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(LocationResponse.self, from: data)
                    if decoded.success {
                        print("Location Updated")
                    } else {
                        print(decoded.message)
                    }
                } catch {
                    print("Location Decode Error:", error)
                }
                
            case .failure(let error):
                print("Location API Error:", error.localizedDescription)
            }
        }
    }
}

// MARK: - Timer

extension DriverHomeVC {
    
    func startLocationUpdates() {
        locationTimer?.invalidate()
        
        locationTimer = Timer.scheduledTimer(
            withTimeInterval: 5,
            repeats: true
        ) { [weak self] _ in
            self?.locationManager.startUpdatingLocation()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationTimer?.invalidate()
        locationTimer = nil
        locationManager.stopUpdatingLocation()
    }
}
