import UIKit

class CustomTabBarController: UIViewController {
    
    let containerView = UIView()
    let tabBarView = UIView()
    
    let homeBtn = UIButton()
    let earningsBtn = UIButton()
    let historyBtn = UIButton()
    let profileBtn = UIButton()
    
    var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showVC(DriverHomeVC())
        selectTab(homeBtn)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height - 86
        )
        view.addSubview(containerView)
        
        tabBarView.frame = CGRect(
            x: 0,
            y: view.frame.height - 86,
            width: view.frame.width,
            height: 86
        )
        tabBarView.backgroundColor = .white
        tabBarView.layer.borderWidth = 1
        tabBarView.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(tabBarView)
        
        setupButton(homeBtn, title: "Home", icon: "house", x: 0, action: #selector(homeTapped))
        setupButton(earningsBtn, title: "Earnings", icon: "doc.text", x: view.frame.width / 4, action: #selector(earningsTapped))
        setupButton(historyBtn, title: "History", icon: "clock", x: view.frame.width / 2, action: #selector(historyTapped))
        setupButton(profileBtn, title: "Profile", icon: "person.fill", x: view.frame.width * 3 / 4, action: #selector(profileTapped))
    }
    
    func setupButton(_ btn: UIButton, title: String, icon: String, x: CGFloat, action: Selector) {
        let width = view.frame.width / 4
        btn.frame = CGRect(x: x, y: 0, width: width, height: 70)
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .gray
        btn.setTitleColor(.gray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 11)
        btn.alignVertical(spacing: 4)
        btn.addTarget(self, action: action, for: .touchUpInside)
        tabBarView.addSubview(btn)
    }
    
    func showVC(_ vc: UIViewController) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        
        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        currentVC = vc
    }
    
    func selectTab(_ selected: UIButton) {
        [homeBtn, earningsBtn, historyBtn, profileBtn].forEach {
            $0.tintColor = .gray
            $0.setTitleColor(.gray, for: .normal)
        }
        
        selected.tintColor = .systemGreen
        selected.setTitleColor(.systemGreen, for: .normal)
    }
    
    @objc func homeTapped() {
        showVC(DriverHomeVC())
        selectTab(homeBtn)
    }
    
    @objc func earningsTapped() {
        showVC(EarningsVC())
        selectTab(earningsBtn)
    }
    
    @objc func historyTapped() {
        showVC(RideHistoryVC())
        selectTab(historyBtn)
    }
    
    @objc func profileTapped() {
        showVC(ProfileVC())
        selectTab(profileBtn)
    }
}
extension UIButton {
    
    func alignVertical(spacing: CGFloat = 4) {
        guard let imageSize = imageView?.image?.size,
              let text = titleLabel?.text,
              let font = titleLabel?.font else { return }
        
        let titleSize = text.size(withAttributes: [.font: font])
        
        titleEdgeInsets = UIEdgeInsets(
            top: spacing,
            left: -imageSize.width,
            bottom: -imageSize.height,
            right: 0
        )
        
        imageEdgeInsets = UIEdgeInsets(
            top: -titleSize.height,
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
    }
}
