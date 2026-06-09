//
//  LoginVC.swift
//  DriverApp
//
//  Created by Coding Brains on 05/06/26.
//

import UIKit
import Alamofire

struct DriverLoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
}

class LoginVC: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    func setupUI() {
            emailView.layer.borderWidth = 1
            emailView.layer.borderColor = UIColor.gray.cgColor
            emailView.layer.cornerRadius = 10

            passwordView.layer.borderWidth = 1
            passwordView.layer.borderColor = UIColor.gray.cgColor
            passwordView.layer.cornerRadius = 10

            loginBtn.layer.cornerRadius = 10
            passwordTF.isSecureTextEntry = true
        }
    func showAlert(_ message: String) {
            let alert = UIAlertController(
                title: "Driver Login",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    func loginAPI() {

            let phone = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if phone.isEmpty {
                showAlert("Please enter phone number")
                return
            }

            if password.isEmpty {
                showAlert("Please enter password")
                return
            }

            let url = "https://unarmored-dropper-blatantly.ngrok-free.dev/api/drivers/login"

            let headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]

            let params: [String: Any] = [
                "phone": phone,
                "password": password
            ]

            print("LOGIN PARAMS:", params)

            loginBtn.isEnabled = false
            loginBtn.setTitle("Please wait...", for: .normal)

            AF.request(
                url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .responseData { response in

                DispatchQueue.main.async {
                    self.loginBtn.isEnabled = true
                    self.loginBtn.setTitle("Login", for: .normal)
                }

                print("LOGIN STATUS:", response.response?.statusCode ?? 0)

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("LOGIN RAW:", raw)
                }

                switch response.result {

                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(
                            DriverLoginResponse.self,
                            from: data
                        )

                        DispatchQueue.main.async {
                            if decoded.success {

                                if let token = decoded.token {
                                    UserDefaults.standard.set(token, forKey: "driverAuthToken")
                                }

                                let vc = CustomTabBarController()
                                let nav = UINavigationController(rootViewController: vc)
                                nav.isNavigationBarHidden = true

                                UIApplication.shared.windows.first?.rootViewController = nav
                                UIApplication.shared.windows.first?.makeKeyAndVisible()

                            } else {
                                self.showAlert(decoded.message)
                            }
                        }

                    } catch {
                        print("Login Decode Error:", error)
                        DispatchQueue.main.async {
                            self.showAlert("Invalid server response")
                        }
                    }

                case .failure(let error):
                    print("Login Error:", error.localizedDescription)
                    DispatchQueue.main.async {
                        self.showAlert("Something went wrong")
                    }
                }
            }
        }
    @IBAction func eyetapped(_ sender: UIButton) {
        passwordTF.isSecureTextEntry.toggle()
               let imageName = passwordTF.isSecureTextEntry ? "eye" : "eye.slash"
        eyeBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        loginAPI()
    }
    @IBAction func signupTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "SignupVC") as! SignupVC

            navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func forgotpasswordBtn(_ sender: UIButton) {
    }
    
   
}
