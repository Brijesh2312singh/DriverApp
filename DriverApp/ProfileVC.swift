//
//  ProfileVC.swift
//  DriverApp
//

import UIKit
import Alamofire

struct DriverProfileAPIResponse: Codable {
    let success: Bool
    let driver: DriverProfileData
}

struct DriverProfileData: Codable {
    let id: Int
    let name: String
    let email: String?
    let phone: String?
    let car_name: String?
    let car_number: String?
    let car_color: String?
}

class ProfileVC: UIViewController {
    
    let baseURL = "https://unarmored-dropper-blatantly.ngrok-free.dev/api"
    
    let profileImageView = UIImageView()
    let nameLbl = UILabel()
    let carLbl = UILabel()
    let ratingLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getProfileAPI()
        loadSavedProfileImage()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        header.backgroundColor = .systemGreen
        view.addSubview(header)
        
        profileImageView.frame = CGRect(x: (view.frame.width - 96) / 2, y: 90, width: 96, height: 96)
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .darkGray
        profileImageView.backgroundColor = .white
        profileImageView.layer.cornerRadius = 48
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        view.addSubview(profileImageView)
        
        let editBtn = UIButton(frame: CGRect(x: profileImageView.frame.maxX - 18, y: profileImageView.frame.maxY - 30, width: 34, height: 34))
        editBtn.backgroundColor = .white
        editBtn.layer.cornerRadius = 17
        editBtn.setImage(UIImage(systemName: "pencil"), for: .normal)
        editBtn.tintColor = .systemGreen
        editBtn.addTarget(self, action: #selector(editProfileImageTapped), for: .touchUpInside)
        view.addSubview(editBtn)
        
        nameLbl.frame = CGRect(x: 20, y: 200, width: view.frame.width - 40, height: 24)
        nameLbl.textAlignment = .center
        nameLbl.font = .boldSystemFont(ofSize: 18)
        view.addSubview(nameLbl)
        
        carLbl.frame = CGRect(x: 20, y: 227, width: view.frame.width - 40, height: 20)
        carLbl.textAlignment = .center
        carLbl.textColor = .gray
        carLbl.font = .systemFont(ofSize: 13)
        view.addSubview(carLbl)
        
        ratingLbl.frame = CGRect(x: 20, y: 250, width: view.frame.width - 40, height: 20)
        ratingLbl.textAlignment = .center
        ratingLbl.text = "★ 4.8"
        ratingLbl.textColor = .orange
        ratingLbl.font = .boldSystemFont(ofSize: 14)
        view.addSubview(ratingLbl)
        
        let line = UIView(frame: CGRect(x: 0, y: 288, width: view.frame.width, height: 1))
        line.backgroundColor = UIColor.systemGray5
        view.addSubview(line)
        
        let items: [(String, String)] = [
            ("car.fill", "My Vehicle"),
            ("building.columns.fill", "Bank Details"),
            ("doc.text.fill", "Documents"),
            ("gearshape.fill", "Settings"),
            ("questionmark.circle.fill", "Help & Support"),
            ("rectangle.portrait.and.arrow.right", "Logout")
        ]
        
        var y: CGFloat = 300
        
        for i in 0..<items.count {
            let row = menuRow(icon: items[i].0, title: items[i].1, y: y, tag: i)
            view.addSubview(row)
            y += 55
        }
    }
    
    func menuRow(icon: String, title: String, y: CGFloat, tag: Int) -> UIView {
        let row = UIView(frame: CGRect(x: 0, y: y, width: view.frame.width, height: 55))
        row.backgroundColor = .white
        row.tag = tag
        row.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(menuTapped(_:)))
        row.addGestureRecognizer(tap)
        
        
        let iconView = UIImageView(frame: CGRect(x: 22, y: 17, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .black
        row.addSubview(iconView)
        
        let titleLbl = UILabel(frame: CGRect(x: 55, y: 0, width: 220, height: 55))
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15)
        row.addSubview(titleLbl)
        
        let arrow = UIImageView(frame: CGRect(x: view.frame.width - 38, y: 18, width: 16, height: 16))
        arrow.image = UIImage(systemName: "chevron.right")
        arrow.tintColor = .black
        row.addSubview(arrow)
        
        let line = UIView(frame: CGRect(x: 20, y: 54, width: view.frame.width - 40, height: 1))
        line.backgroundColor = UIColor.systemGray5
        row.addSubview(line)
        
        return row
    }
    
    @objc func menuTapped(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        
        switch tag {
        case 5:
            showLogoutAlert()
        default:
            break
        }
    }
    
    @objc func editProfileImageTapped() {
        let alert = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.openImagePicker(source: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openImagePicker(source: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func openImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("Source not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "driverProfileImage")
        }
    }
    
    func loadSavedProfileImage() {
        if let data = UserDefaults.standard.data(forKey: "driverProfileImage"),
           let image = UIImage(data: data) {
            profileImageView.image = image
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.logoutUser()
        })
        
        present(alert, animated: true)
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "driverAuthToken")
        UserDefaults.standard.removeObject(forKey: "driverProfileImage")
        UserDefaults.standard.synchronize()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginVC"
        ) as? LoginVC else {
            print("LoginVC storyboard id missing")
            return
        }

        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    func getProfileAPI() {
        AF.request(
            "\(baseURL)/drivers/profile",
            method: .get,
            headers: authHeaders()
        )
        .responseData { response in
            
            guard let data = response.data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(DriverProfileAPIResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.nameLbl.text = decoded.driver.name
                    self.carLbl.text = "\(decoded.driver.car_name ?? "") • \(decoded.driver.car_number ?? "")"
                }
                
            } catch {
                print("PROFILE DECODE ERROR:", error)
            }
        }
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        let image = info[.editedImage] as? UIImage
            ?? info[.originalImage] as? UIImage
        
        guard let selectedImage = image else { return }
        
        profileImageView.image = selectedImage
        saveProfileImage(selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
