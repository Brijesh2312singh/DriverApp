import UIKit
import Alamofire

struct EarningsResponse: Codable {
    let success: Bool
    let earnings: EarningsData
}

struct EarningsData: Codable {
    let today: String
    let week: String
    let month: String
    let total: String
}

struct DriverHistoryResponse: Codable {
    let success: Bool
    let rides: [DriverRide]
}

struct DriverRide: Codable {
    let id: Int
    let price: String?
    let status: String?
    let passenger_name: String?
    let ride_time: String?
    let payment_method: String?
}

class EarningsVC: UIViewController {
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let totalEarningsLbl = UILabel()
    let ridesCountLbl = UILabel()
    let onlineTimeLbl = UILabel()
    let recentStack = UIStackView()
    let viewAllBtn = UIButton()
    
    var allCompletedRides: [DriverRide] = []
    var recentRides: [DriverRide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDefaultData()
        getEarningsAPI()
        getDriverHistoryAPI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Earnings"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 17)
        view.addSubview(titleLbl)
        
        let filterView = UIView(frame: CGRect(x: 20, y: 105, width: view.frame.width - 40, height: 46))
        filterView.layer.cornerRadius = 10
        filterView.layer.borderWidth = 1
        filterView.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(filterView)
        
        let filterLbl = UILabel(frame: CGRect(x: 14, y: 0, width: 120, height: 46))
        filterLbl.text = "Today ⌄"
        filterLbl.font = .systemFont(ofSize: 14)
        filterView.addSubview(filterLbl)
        
        let totalTitle = UILabel(frame: CGRect(x: 0, y: 185, width: view.frame.width, height: 20))
        totalTitle.text = "Total Earnings"
        totalTitle.textAlignment = .center
        totalTitle.font = .boldSystemFont(ofSize: 13)
        view.addSubview(totalTitle)
        
        totalEarningsLbl.frame = CGRect(x: 0, y: 210, width: view.frame.width, height: 42)
        totalEarningsLbl.textAlignment = .center
        totalEarningsLbl.font = .boldSystemFont(ofSize: 34)
        view.addSubview(totalEarningsLbl)
        
        view.addSubview(statCard(x: 20, y: 285, title: "Rides", valueLabel: ridesCountLbl))
        view.addSubview(statCard(x: view.frame.width / 2 + 8, y: 285, title: "Online Time", valueLabel: onlineTimeLbl))
        
        let recentTitle = UILabel(frame: CGRect(x: 20, y: 385, width: 150, height: 22))
        recentTitle.text = "Recent Rides"
        recentTitle.font = .boldSystemFont(ofSize: 14)
        view.addSubview(recentTitle)
        
        recentStack.frame = CGRect(x: 20, y: 410, width: view.frame.width - 40, height: 175)
        recentStack.axis = .vertical
        recentStack.distribution = .fillEqually
        recentStack.alignment = .fill
        recentStack.spacing = 8
        view.addSubview(recentStack)
        
        viewAllBtn.frame = CGRect(x: 20, y: view.frame.height - 90, width: view.frame.width - 40, height: 52)
        viewAllBtn.layer.cornerRadius = 10
        viewAllBtn.layer.borderWidth = 1
        viewAllBtn.layer.borderColor = UIColor.systemGray4.cgColor
        viewAllBtn.setTitle("View All", for: .normal)
        viewAllBtn.setTitleColor(.systemGreen, for: .normal)
        viewAllBtn.titleLabel?.font = .boldSystemFont(ofSize: 15)
        viewAllBtn.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
        view.addSubview(viewAllBtn)
    }
    
    func statCard(x: CGFloat, y: CGFloat, title: String, valueLabel: UILabel) -> UIView {
        let card = UIView(frame: CGRect(x: x, y: y, width: (view.frame.width - 56) / 2, height: 72))
        card.layer.cornerRadius = 10
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 12, width: card.frame.width, height: 18))
        titleLbl.text = title
        titleLbl.textAlignment = .center
        titleLbl.font = .systemFont(ofSize: 13)
        card.addSubview(titleLbl)
        
        valueLabel.frame = CGRect(x: 0, y: 32, width: card.frame.width, height: 28)
        valueLabel.textAlignment = .center
        valueLabel.font = .boldSystemFont(ofSize: 22)
        card.addSubview(valueLabel)
        
        return card
    }
    
    func setDefaultData() {
        totalEarningsLbl.text = "₹0.00"
        ridesCountLbl.text = "0"
        onlineTimeLbl.text = "6h 45m"
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    func getEarningsAPI() {
        AF.request(
            "\(baseURL)/drivers/earnings",
            method: .get,
            headers: authHeaders()
        )
        .responseData { response in
            
            guard let data = response.data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(EarningsResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.totalEarningsLbl.text = "₹\(decoded.earnings.total)"
                }
                
            } catch {
                print("EARNINGS DECODE ERROR:", error)
            }
        }
    }
    
    func getDriverHistoryAPI() {
        AF.request(
            "\(baseURL)/rides/driver/history",
            method: .get,
            headers: authHeaders()
        )
        .responseData { response in
            
            guard let data = response.data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(DriverHistoryResponse.self, from: data)
                
                let completedRides = decoded.rides.filter {
                    ($0.status ?? "").lowercased() == "completed"
                }
                
                self.allCompletedRides = completedRides
                self.recentRides = Array(completedRides.prefix(3))
                
                DispatchQueue.main.async {
                    self.ridesCountLbl.text = "\(completedRides.count)"
                    self.reloadRecentRides()
                }
                
            } catch {
                print("HISTORY DECODE ERROR:", error)
            }
        }
    }
    
    func reloadRecentRides() {
        recentStack.arrangedSubviews.forEach {
            recentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for ride in recentRides {
            recentStack.addArrangedSubview(
                recentRideRow(
                    name: ride.passenger_name ?? "Passenger",
                    fare: "₹\(ride.price ?? "0.00")",
                    time: ride.ride_time ?? ""
                )
            )
        }
    }
    
    func recentRideRow(name: String, fare: String, time: String) -> UIView {
        
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(systemName: "person.circle.fill")
        img.tintColor = .darkGray
        row.addSubview(img)
        
        let nameLbl = UILabel()
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.text = name
        nameLbl.font = .boldSystemFont(ofSize: 14)
        row.addSubview(nameLbl)
        
        let fareLbl = UILabel()
        fareLbl.translatesAutoresizingMaskIntoConstraints = false
        fareLbl.text = fare
        fareLbl.textAlignment = .right
        fareLbl.font = .boldSystemFont(ofSize: 14)
        row.addSubview(fareLbl)
        
        let timeLbl = UILabel()
        timeLbl.translatesAutoresizingMaskIntoConstraints = false
        timeLbl.text = time
        timeLbl.textAlignment = .right
        timeLbl.textColor = .gray
        timeLbl.font = .systemFont(ofSize: 11)
        row.addSubview(timeLbl)
        
        NSLayoutConstraint.activate([
            img.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            img.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 30),
            img.heightAnchor.constraint(equalToConstant: 30),
            
            nameLbl.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 14),
            nameLbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),
            nameLbl.trailingAnchor.constraint(lessThanOrEqualTo: fareLbl.leadingAnchor, constant: -8),
            
            fareLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            fareLbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),
            fareLbl.widthAnchor.constraint(equalToConstant: 100),
            
            timeLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            timeLbl.topAnchor.constraint(equalTo: fareLbl.bottomAnchor, constant: 2),
            timeLbl.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return row
    }
    
    @objc func viewAllTapped() {
        let vc = RideHistoryVC()
        vc.rides = allCompletedRides
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

class RideHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rides: [DriverRide] = []
    var filteredRides: [DriverRide] = []
    
    let tableView = UITableView()
    
    let allBtn = UIButton()
    let completedBtn = UIButton()
    let cancelledBtn = UIButton()
    
    var selectedTab = "all"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredRides = rides
        setupUI()
        updateTabUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        let backBtn = UIButton(frame: CGRect(x: 16, y: 55, width: 36, height: 36))
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 58, width: view.frame.width, height: 30))
        titleLbl.text = "Ride History"
        titleLbl.textAlignment = .center
        titleLbl.font = .boldSystemFont(ofSize: 17)
        view.addSubview(titleLbl)
        
        setupTabs()
        
        tableView.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 150)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 74
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func setupTabs() {
        let startX: CGFloat = 24
        let y: CGFloat = 105
        let gap: CGFloat = 10
        let w: CGFloat = (view.frame.width - 48 - 20) / 3
        
        setupTabButton(allBtn, title: "All", frame: CGRect(x: startX, y: y, width: w, height: 36), action: #selector(allTapped))
        setupTabButton(completedBtn, title: "Completed", frame: CGRect(x: startX + w + gap, y: y, width: w, height: 36), action: #selector(completedTapped))
        setupTabButton(cancelledBtn, title: "Cancelled", frame: CGRect(x: startX + (w + gap) * 2, y: y, width: w, height: 36), action: #selector(cancelledTapped))
    }
    
    func setupTabButton(_ button: UIButton, title: String, frame: CGRect, action: Selector) {
        button.frame = frame
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
    
    func updateTabUI() {
        let buttons = [
            ("all", allBtn),
            ("completed", completedBtn),
            ("cancelled", cancelledBtn)
        ]
        
        for item in buttons {
            let isSelected = item.0 == selectedTab
            item.1.backgroundColor = isSelected ? .systemGreen : .white
            item.1.setTitleColor(isSelected ? .white : .black, for: .normal)
        }
    }
    
    func filterRides() {
        if selectedTab == "all" {
            filteredRides = rides
        } else {
            filteredRides = rides.filter {
                ($0.status ?? "").lowercased() == selectedTab
            }
        }
        
        updateTabUI()
        tableView.reloadData()
    }
    
    @objc func allTapped() {
        selectedTab = "all"
        filterRides()
    }
    
    @objc func completedTapped() {
        selectedTab = "completed"
        filterRides()
    }
    
    @objc func cancelledTapped() {
        selectedTab = "cancelled"
        filterRides()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRides.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let ride = filteredRides[indexPath.row]
        let status = (ride.status ?? "").lowercased()
        
        let img = UIImageView(frame: CGRect(x: 22, y: 18, width: 38, height: 38))
        img.image = UIImage(systemName: "person.circle.fill")
        img.tintColor = .darkGray
        cell.contentView.addSubview(img)
        
        let nameLbl = UILabel(frame: CGRect(x: 72, y: 12, width: 160, height: 22))
        nameLbl.text = ride.passenger_name ?? "Passenger"
        nameLbl.font = .boldSystemFont(ofSize: 14)
        cell.contentView.addSubview(nameLbl)
        
        let timeLbl = UILabel(frame: CGRect(x: 72, y: 37, width: 170, height: 18))
        timeLbl.text = ride.ride_time ?? ""
        timeLbl.textColor = .gray
        timeLbl.font = .systemFont(ofSize: 12)
        cell.contentView.addSubview(timeLbl)
        
        let fareLbl = UILabel(frame: CGRect(x: view.frame.width - 125, y: 12, width: 105, height: 22))
        fareLbl.text = "₹\(ride.price ?? "0.00")"
        fareLbl.textAlignment = .right
        fareLbl.font = .boldSystemFont(ofSize: 14)
        cell.contentView.addSubview(fareLbl)
        
        let statusLbl = UILabel(frame: CGRect(x: view.frame.width - 125, y: 37, width: 105, height: 18))
        statusLbl.text = (ride.status ?? "").capitalized
        statusLbl.textAlignment = .right
        statusLbl.font = .systemFont(ofSize: 12)
        statusLbl.textColor = status == "completed" ? .systemGreen : .systemRed
        cell.contentView.addSubview(statusLbl)
        
        return cell
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
