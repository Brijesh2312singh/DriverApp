//
//  RideRequestVC.swift
//  DriverApp
//

import UIKit
import GoogleMaps

class RideRequestVC: UIViewController {

    let mapView = GMSMapView()

    let backBtn = UIButton()
    let titleLbl = UILabel()

    let cardView = UIView()

    let distanceLbl = UILabel()

    let pickupDot = UIView()
    let pickupTitleLbl = UILabel()
    let pickupLbl = UILabel()

    let dropDot = UIView()
    let dropTitleLbl = UILabel()
    let dropLbl = UILabel()

    let fareTitleLbl = UILabel()
    let fareLbl = UILabel()

    let timerCircleView = UIView()
    let timerLbl = UILabel()
    let secLbl = UILabel()

    let acceptBtn = UIButton()
    let rejectBtn = UIButton()

    var countdown = 15
    var timer: Timer?

    // API Values
    
    var rideId: Int = 0

    var pickupAddress = ""
    var pickupLat: Double = 0
    var pickupLng: Double = 0

    var dropAddress = ""
    var dropLat: Double = 0
    var dropLng: Double = 0

    var fare = ""
    var distance = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupMap()
        setupHeader()
        setupCard()

        startCountdown()
    }

    // MARK: - Header

    func setupHeader() {

        backBtn.frame = CGRect(x: 20, y: 55, width: 35, height: 35)
        backBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)

        titleLbl.frame = CGRect(
            x: 80,
            y: 55,
            width: view.frame.width - 160,
            height: 35
        )

        titleLbl.text = "New Ride Request"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 18)

        view.addSubview(titleLbl)
    }

    // MARK: - Map

    func setupMap() {

        mapView.frame = CGRect(
            x: 0,
            y: 100,
            width: view.frame.width,
            height: 220
        )

        view.addSubview(mapView)

        let pickup = CLLocationCoordinate2D(latitude: pickupLat, longitude: pickupLng)
        let drop = CLLocationCoordinate2D(latitude: dropLat, longitude: dropLng)

        let pickupMarker = GMSMarker(position: pickup)
        pickupMarker.icon = GMSMarker.markerImage(with: .black)
        pickupMarker.map = mapView

        let dropMarker = GMSMarker(position: drop)
        dropMarker.icon = GMSMarker.markerImage(with: .blue)
        dropMarker.map = mapView

        let path = GMSMutablePath()
        path.add(pickup)
        path.add(drop)

        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4
        polyline.strokeColor = .black
        polyline.map = mapView

        let bounds = GMSCoordinateBounds(
            coordinate: pickup,
            coordinate: drop
        )

        mapView.animate(
            with: GMSCameraUpdate.fit(
                bounds,
                withPadding: 60
            )
        )
    }

    // MARK: - Card

    func setupCard() {

        cardView.frame = CGRect(
            x: 16,
            y: view.frame.height - 400,
            width: view.frame.width - 32,
            height: 360
        )

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10

        view.addSubview(cardView)

        distanceLbl.frame = CGRect(
            x: 20,
            y: 18,
            width: 150,
            height: 25
        )

        distanceLbl.text = distance
        distanceLbl.font = .boldSystemFont(ofSize: 16)

        cardView.addSubview(distanceLbl)

        // Pickup

        pickupDot.frame = CGRect(x: 25, y: 75, width: 10, height: 10)
        pickupDot.backgroundColor = .systemGreen
        pickupDot.layer.cornerRadius = 5
        cardView.addSubview(pickupDot)

        pickupTitleLbl.frame = CGRect(x: 50, y: 60, width: 60, height: 18)
        pickupTitleLbl.text = "Pickup"
        pickupTitleLbl.font = .systemFont(ofSize: 12)
        pickupTitleLbl.textColor = .gray
        cardView.addSubview(pickupTitleLbl)

        pickupLbl.frame = CGRect(
            x: 50,
            y: 80,
            width: cardView.frame.width - 70,
            height: 22
        )

        pickupLbl.text = pickupAddress
        pickupLbl.font = .boldSystemFont(ofSize: 14)
        cardView.addSubview(pickupLbl)

        // Drop

        dropDot.frame = CGRect(x: 25, y: 135, width: 10, height: 10)
        dropDot.backgroundColor = .systemRed
        dropDot.layer.cornerRadius = 5
        cardView.addSubview(dropDot)

        dropTitleLbl.frame = CGRect(x: 50, y: 120, width: 60, height: 18)
        dropTitleLbl.text = "Drop"
        dropTitleLbl.font = .systemFont(ofSize: 12)
        dropTitleLbl.textColor = .gray
        cardView.addSubview(dropTitleLbl)

        dropLbl.frame = CGRect(
            x: 50,
            y: 140,
            width: cardView.frame.width - 70,
            height: 22
        )

        dropLbl.text = dropAddress
        dropLbl.font = .boldSystemFont(ofSize: 14)
        cardView.addSubview(dropLbl)

        // Fare

        fareTitleLbl.frame = CGRect(
            x: 20,
            y: 190,
            width: 120,
            height: 22
        )

        fareTitleLbl.text = "Estimated Fare"
        fareTitleLbl.textColor = .gray
        fareTitleLbl.font = .systemFont(ofSize: 13)

        cardView.addSubview(fareTitleLbl)

        fareLbl.frame = CGRect(
            x: cardView.frame.width - 100,
            y: 182,
            width: 80,
            height: 30
        )

        fareLbl.text = fare
        fareLbl.textAlignment = .right
        fareLbl.font = .boldSystemFont(ofSize: 26)

        cardView.addSubview(fareLbl)

        setupButtons()
    }

    // MARK: - Buttons

    func setupButtons() {

        timerCircleView.frame = CGRect(
            x: 20,
            y: 250,
            width: 60,
            height: 60
        )

        timerCircleView.layer.cornerRadius = 30
        timerCircleView.layer.borderWidth = 2
        timerCircleView.layer.borderColor = UIColor.systemGreen.cgColor

        cardView.addSubview(timerCircleView)

        timerLbl.frame = CGRect(x: 0, y: 10, width: 60, height: 22)
        timerLbl.textAlignment = .center
        timerLbl.font = .boldSystemFont(ofSize: 22)

        timerCircleView.addSubview(timerLbl)

        secLbl.frame = CGRect(x: 0, y: 32, width: 60, height: 14)
        secLbl.text = "sec"
        secLbl.textAlignment = .center
        secLbl.font = .systemFont(ofSize: 10)

        timerCircleView.addSubview(secLbl)

        acceptBtn.frame = CGRect(
            x: 95,
            y: 255,
            width: cardView.frame.width - 115,
            height: 50
        )

        acceptBtn.backgroundColor = .systemGreen
        acceptBtn.layer.cornerRadius = 10
        acceptBtn.setTitle("Accept", for: .normal)

        acceptBtn.addTarget(
            self,
            action: #selector(acceptTapped),
            for: .touchUpInside
        )

        cardView.addSubview(acceptBtn)

        rejectBtn.frame = CGRect(
            x: 20,
            y: 315,
            width: cardView.frame.width - 40,
            height: 30
        )

        rejectBtn.setTitle("Reject", for: .normal)
        rejectBtn.setTitleColor(.systemRed, for: .normal)

        rejectBtn.addTarget(
            self,
            action: #selector(rejectTapped),
            for: .touchUpInside
        )

        cardView.addSubview(rejectBtn)
    }

    // MARK: - Countdown

    func startCountdown() {

        timerLbl.text = "\(countdown)"

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in

            self.countdown -= 1

            self.timerLbl.text = "\(self.countdown)"

            if self.countdown <= 0 {

                self.timer?.invalidate()

                self.dismiss(animated: true)
            }
        }
    }

    // MARK: - Actions

    @objc func acceptTapped() {

        timer?.invalidate()

        print("Ride Accepted")

        // Accept Ride API Call
    }

    @objc func rejectTapped() {

        timer?.invalidate()

        print("Ride Rejected")

        dismiss(animated: true)
    }

    @objc func backTapped() {

        timer?.invalidate()

        dismiss(animated: true)
    }

    deinit {
        timer?.invalidate()
    }
}
