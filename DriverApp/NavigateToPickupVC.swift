//
//  NavigateToPickupVC.swift
//  DriverApp
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

class NavigateToPickupVC: UIViewController {
    
    var rideId: Int = 0
    
    var pickupAddress: String = ""
    var pickupLat: Double = 0
    var pickupLng: Double = 0
    
    var driverLat: Double = 0
    var driverLng: Double = 0
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let mapView = GMSMapView()
    let locationManager = CLLocationManager()
    
    var passengerName: String = ""
    var passengerPhone: String = ""
    
    var dropAddress: String = ""
    var fare: String = ""
    var distance: String = ""
    var dropLat: Double = 0
    var dropLng: Double = 0
    
    let bottomCard = UIView()
    let distanceLbl = UILabel()
    let titleLbl = UILabel()
    let addressLbl = UILabel()
    let arrivedBtn = UIButton()
    
    var driverMarker: GMSMarker?
    var pickupMarker: GMSMarker?
    var routePolyline: GMSPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupMap()
        setupTopBar()
        setupBottomCard()
        setupLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func setupTopBar() {
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 40, height: 40))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let navTitle = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 35))
        navTitle.text = "Navigate to Pickup"
        navTitle.textAlignment = .center
        navTitle.font = .boldSystemFont(ofSize: 16)
        view.addSubview(navTitle)
    }
    
    func setupMap() {
        mapView.frame = CGRect(x: 0, y: 105, width: view.frame.width, height: view.frame.height - 105)
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
    }
    
    func setupBottomCard() {
        bottomCard.frame = CGRect(
            x: 18,
            y: view.frame.height - 170,
            width: view.frame.width - 36,
            height: 140
        )
        bottomCard.backgroundColor = .white
        bottomCard.layer.cornerRadius = 18
        bottomCard.layer.shadowColor = UIColor.black.cgColor
        bottomCard.layer.shadowOpacity = 0.16
        bottomCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        bottomCard.layer.shadowRadius = 10
        view.addSubview(bottomCard)
        
        let iconView = UIView(frame: CGRect(x: 18, y: 18, width: 46, height: 46))
        iconView.backgroundColor = .systemBlue
        iconView.layer.cornerRadius = 23
        bottomCard.addSubview(iconView)
        
        let arrowIcon = UIImageView(frame: CGRect(x: 12, y: 12, width: 22, height: 22))
        arrowIcon.image = UIImage(systemName: "location.north.fill")
        arrowIcon.tintColor = .white
        iconView.addSubview(arrowIcon)
        
        distanceLbl.frame = CGRect(x: 80, y: 16, width: 180, height: 26)
        distanceLbl.font = .boldSystemFont(ofSize: 22)
        bottomCard.addSubview(distanceLbl)
        
        titleLbl.frame = CGRect(x: 80, y: 43, width: 180, height: 18)
        titleLbl.text = "to Pickup"
        titleLbl.font = .boldSystemFont(ofSize: 14)
        bottomCard.addSubview(titleLbl)
        
        addressLbl.frame = CGRect(x: 80, y: 63, width: bottomCard.frame.width - 100, height: 36)
        addressLbl.font = .systemFont(ofSize: 13)
        addressLbl.textColor = .darkGray
        addressLbl.numberOfLines = 2
        bottomCard.addSubview(addressLbl)
        
        arrivedBtn.frame = CGRect(x: 18, y: 100, width: bottomCard.frame.width - 36, height: 34)
        arrivedBtn.backgroundColor = .systemGreen
        arrivedBtn.setTitle("I've Arrived", for: .normal)
        arrivedBtn.setTitleColor(.white, for: .normal)
        arrivedBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        arrivedBtn.layer.cornerRadius = 8
        arrivedBtn.addTarget(self, action: #selector(arrivedTapped), for: .touchUpInside)
        bottomCard.addSubview(arrivedBtn)
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func drawRoute() {
        guard pickupLat != 0, pickupLng != 0, driverLat != 0, driverLng != 0 else {
            print("Invalid coordinates")
            return
        }
        
        let driverCoord = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLng)
        let pickupCoord = CLLocationCoordinate2D(latitude: pickupLat, longitude: pickupLng)
        
        if driverMarker == nil {
            driverMarker = GMSMarker(position: driverCoord)
            driverMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
            driverMarker?.title = "You"
            driverMarker?.map = mapView
        } else {
            driverMarker?.position = driverCoord
        }
        
        if pickupMarker == nil {
            pickupMarker = GMSMarker(position: pickupCoord)
            pickupMarker?.icon = GMSMarker.markerImage(with: .black)
            pickupMarker?.title = "Pickup"
            pickupMarker?.map = mapView
        }
        
        routePolyline?.map = nil
        
        let path = GMSMutablePath()
        path.add(driverCoord)
        path.add(pickupCoord)
        
        routePolyline = GMSPolyline(path: path)
        routePolyline?.strokeColor = .systemBlue
        routePolyline?.strokeWidth = 5
        routePolyline?.map = mapView
        
        let distance = calculateDistanceKm(
            lat1: driverLat,
            lng1: driverLng,
            lat2: pickupLat,
            lng2: pickupLng
        )
        
        distanceLbl.text = "\(String(format: "%.1f", distance)) km"
        addressLbl.text = pickupAddress
        
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
                if response.response?.statusCode == 200 {
                    let vc = ArrivedAtPickupVC()

                    vc.rideId = self.rideId
                    vc.passengerName = self.passengerName
                    vc.passengerPhone = self.passengerPhone
                    vc.pickupAddress = self.pickupAddress
                    vc.dropAddress = self.dropAddress
                    vc.fare = self.fare
                    vc.distance = self.distance
                    vc.dropLat = self.dropLat
                    vc.dropLng = self.dropLng
                    vc.pickupLat = self.pickupLat
                    vc.pickupLng = self.pickupLng
                    

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension NavigateToPickupVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            mapView.isMyLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        driverLat = location.coordinate.latitude
        driverLng = location.coordinate.longitude
        
        drawRoute()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }
}
