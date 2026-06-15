//
//  LiveRideVC.swift
//  DriverApp
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

class LiveRideVC: UIViewController {
    
    var rideId: Int = 0
    var passengerName: String = ""
    var passengerPhone: String = ""
    var pickupAddress: String = ""
    var dropAddress: String = ""
    var fare: String = ""
    
    var driverLat: Double = 0
    var driverLng: Double = 0
    var dropLat: Double = 0
    var dropLng: Double = 0
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let mapView = GMSMapView()
    let locationManager = CLLocationManager()
    
    var isFakeRide = true
    
    let bottomCard = UIView()
    let nameLbl = UILabel()
    let ratingLbl = UILabel()
    let timeLbl = UILabel()
    let timeSubLbl = UILabel()
    let distanceLbl = UILabel()
    let distanceSubLbl = UILabel()
    let endRideBtn = UIButton()
    
    var fakeMoveTimer: Timer?
    var driverMarker: GMSMarker?
    var dropMarker: GMSMarker?
    var routePolyline: GMSPolyline?
    var isCompletingRide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupMap()
        setupTopBar()
        setupBottomCard()
        
        print("LIVE RIDE ID:", rideId)
        print("LIVE FARE:", fare)
        print("LIVE DRIVER:", driverLat, driverLng)
        print("LIVE DROP:", dropLat, dropLng)
        
        if isFakeRide {
            setupFakeMovement()
        } else {
            setupLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        fakeMoveTimer?.invalidate()
        fakeMoveTimer = nil
    }
    
    func setupTopBar() {
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Live Ride"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 16)
        view.addSubview(titleLbl)
        
        let sosBtn = UIButton(frame: CGRect(x: view.frame.width - 70, y: 55, width: 52, height: 34))
        sosBtn.setTitle("SOS", for: .normal)
        sosBtn.setTitleColor(.systemRed, for: .normal)
        sosBtn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        sosBtn.layer.cornerRadius = 17
        sosBtn.layer.borderWidth = 1
        sosBtn.layer.borderColor = UIColor.systemRed.cgColor
        view.addSubview(sosBtn)
    }
    
    func setupMap() {
        mapView.frame = CGRect(x: 0, y: 105, width: view.frame.width, height: view.frame.height - 105)
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
    }
    
    func setupBottomCard() {
        bottomCard.frame = CGRect(x: 16, y: view.frame.height - 235, width: view.frame.width - 32, height: 205)
        bottomCard.backgroundColor = .white
        bottomCard.layer.cornerRadius = 18
        bottomCard.layer.shadowColor = UIColor.black.cgColor
        bottomCard.layer.shadowOpacity = 0.16
        bottomCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        bottomCard.layer.shadowRadius = 10
        view.addSubview(bottomCard)
        
        let profile = UIImageView(frame: CGRect(x: 18, y: 18, width: 54, height: 54))
        profile.image = UIImage(systemName: "person.circle.fill")
        profile.tintColor = .darkGray
        profile.contentMode = .scaleAspectFill
        profile.layer.cornerRadius = 27
        profile.clipsToBounds = true
        bottomCard.addSubview(profile)
        
        nameLbl.frame = CGRect(x: 85, y: 20, width: 150, height: 22)
        nameLbl.font = .boldSystemFont(ofSize: 16)
        nameLbl.text = passengerName.isEmpty ? "Passenger" : passengerName
        bottomCard.addSubview(nameLbl)
        
        ratingLbl.frame = CGRect(x: 85, y: 45, width: 80, height: 20)
        ratingLbl.text = "4.8 ★"
        ratingLbl.textColor = .orange
        ratingLbl.font = .boldSystemFont(ofSize: 14)
        bottomCard.addSubview(ratingLbl)
        
        let callBtn = circleButton(x: bottomCard.frame.width - 105, y: 22, icon: "phone.fill")
        callBtn.addTarget(self, action: #selector(callPassenger), for: .touchUpInside)
        bottomCard.addSubview(callBtn)
        
        let chatBtn = circleButton(x: bottomCard.frame.width - 58, y: 22, icon: "message.fill")
        bottomCard.addSubview(chatBtn)
        
        let line1 = UIView(frame: CGRect(x: 15, y: 84, width: bottomCard.frame.width - 30, height: 1))
        line1.backgroundColor = UIColor.systemGray5
        bottomCard.addSubview(line1)
        
        let leftX: CGFloat = 25
        let rightX: CGFloat = bottomCard.frame.width / 2 + 25
        
        timeLbl.frame = CGRect(x: leftX, y: 102, width: 130, height: 32)
        timeLbl.font = .boldSystemFont(ofSize: 24)
        timeLbl.text = "-- min"
        bottomCard.addSubview(timeLbl)
        
        timeSubLbl.frame = CGRect(x: leftX, y: 137, width: 130, height: 22)
        timeSubLbl.text = "to drop"
        timeSubLbl.textColor = .gray
        timeSubLbl.font = .systemFont(ofSize: 14)
        bottomCard.addSubview(timeSubLbl)
        
        let divider = UIView(frame: CGRect(x: bottomCard.frame.width / 2, y: 100, width: 1, height: 64))
        divider.backgroundColor = UIColor.systemGray5
        bottomCard.addSubview(divider)
        
        distanceLbl.frame = CGRect(x: rightX, y: 102, width: 140, height: 32)
        distanceLbl.font = .boldSystemFont(ofSize: 24)
        distanceLbl.text = "-- km"
        bottomCard.addSubview(distanceLbl)
        
        distanceSubLbl.frame = CGRect(x: rightX, y: 137, width: 140, height: 22)
        distanceSubLbl.text = "remaining"
        distanceSubLbl.textColor = .gray
        distanceSubLbl.font = .systemFont(ofSize: 14)
        bottomCard.addSubview(distanceSubLbl)
        
        endRideBtn.frame = CGRect(x: 18, y: bottomCard.frame.height - 48, width: bottomCard.frame.width - 36, height: 40)
        endRideBtn.backgroundColor = .white
        endRideBtn.setTitle("End Ride", for: .normal)
        endRideBtn.setTitleColor(.systemRed, for: .normal)
        endRideBtn.titleLabel?.font = .boldSystemFont(ofSize: 15)
        endRideBtn.layer.cornerRadius = 8
        endRideBtn.layer.borderWidth = 1
        endRideBtn.layer.borderColor = UIColor.systemRed.cgColor
        endRideBtn.addTarget(self, action: #selector(endRideTapped), for: .touchUpInside)
        bottomCard.addSubview(endRideBtn)
    }
    
    func circleButton(x: CGFloat, y: CGFloat, icon: String) -> UIButton {
        let btn = UIButton(frame: CGRect(x: x, y: y, width: 38, height: 38))
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 19
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray5.cgColor
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .systemGreen
        return btn
    }
    
    func setupFakeMovement() {
        if driverLat == 0 || driverLng == 0 {
            driverLat = 26.848553873060247
            driverLng = 80.98178143991868
        }
        
        drawRoute()
        
        fakeMoveTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let step = 0.03
            self.driverLat = self.driverLat + (self.dropLat - self.driverLat) * step
            self.driverLng = self.driverLng + (self.dropLng - self.driverLng) * step
            
            self.drawRoute()
            self.updateDriverLocationAPI()
            
            let distance = self.calculateDistanceKm(
                lat1: self.driverLat,
                lng1: self.driverLng,
                lat2: self.dropLat,
                lng2: self.dropLng
            )
            
            if distance <= 0.05 {
                timer.invalidate()
                self.fakeMoveTimer = nil
                print("Driver reached drop")
                self.endRideTapped()
            }
        }
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func drawRoute() {
        guard dropLat != 0,
              dropLng != 0,
              driverLat != 0,
              driverLng != 0 else {
            print("Invalid live ride coordinates")
            print("Driver:", driverLat, driverLng)
            print("Drop:", dropLat, dropLng)
            return
        }
        
        let driverCoord = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLng)
        let dropCoord = CLLocationCoordinate2D(latitude: dropLat, longitude: dropLng)
        
        if driverMarker == nil {
            driverMarker = GMSMarker(position: driverCoord)
            driverMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
            driverMarker?.title = "You"
            driverMarker?.map = mapView
        } else {
            driverMarker?.position = driverCoord
        }
        
        if dropMarker == nil {
            dropMarker = GMSMarker(position: dropCoord)
            dropMarker?.icon = GMSMarker.markerImage(with: .black)
            dropMarker?.title = "Drop"
            dropMarker?.map = mapView
        }
        
        routePolyline?.map = nil
        
        let path = GMSMutablePath()
        path.add(driverCoord)
        path.add(dropCoord)
        
        routePolyline = GMSPolyline(path: path)
        routePolyline?.strokeColor = .systemBlue
        routePolyline?.strokeWidth = 5
        routePolyline?.map = mapView
        
        let distance = calculateDistanceKm(
            lat1: driverLat,
            lng1: driverLng,
            lat2: dropLat,
            lng2: dropLng
        )
        
        let eta = max(1, Int(ceil((distance / 30.0) * 60.0)))
        
        timeLbl.text = "\(eta) min"
        distanceLbl.text = "\(String(format: "%.1f", distance)) km"
        
        let camera = GMSCameraPosition.camera(
            withLatitude: driverLat,
            longitude: driverLng,
            zoom: 16
        )
        mapView.animate(to: camera)
    }
    
    func calculateDistanceKm(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let location1 = CLLocation(latitude: lat1, longitude: lng1)
        let location2 = CLLocation(latitude: lat2, longitude: lng2)
        return location1.distance(from: location2) / 1000
    }
    
    func updateDriverLocationAPI() {
        let params: [String: Any] = [
            "lat": driverLat,
            "lng": driverLng
        ]
        
        AF.request(
            "\(baseURL)/drivers/update-location",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .responseData { response in
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("LIVE LOCATION RAW:", raw)
            }
            
            print("LIVE LOCATION STATUS:", response.response?.statusCode ?? 0)
        }
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    @objc func endRideTapped() {
        if isCompletingRide { return }
        isCompletingRide = true
        
        endRideBtn.isEnabled = false
        endRideBtn.setTitle("Ending...", for: .normal)
        
        fakeMoveTimer?.invalidate()
        fakeMoveTimer = nil
        
        updateDriverLocationAPI()
        
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
                print("COMPLETE RIDE RAW:", raw)
            }
            
            print("COMPLETE RIDE STATUS:", response.response?.statusCode ?? 0)
            
            DispatchQueue.main.async {
                if response.response?.statusCode == 200 {
                    let vc = RideCompletedVC()
                    vc.fare = self.fare
                    vc.paymentMethod = "Cash"
                    vc.passengerName = self.passengerName
                    vc.pickupAddress = self.pickupAddress
                    vc.dropAddress = self.dropAddress
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.isCompletingRide = false
                    self.endRideBtn.isEnabled = true
                    self.endRideBtn.setTitle("End Ride", for: .normal)
                }
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

extension LiveRideVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            mapView.isMyLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isFakeRide { return }
        
        guard let location = locations.last else { return }
        
        driverLat = location.coordinate.latitude
        driverLng = location.coordinate.longitude
        
        drawRoute()
        updateDriverLocationAPI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }
}
