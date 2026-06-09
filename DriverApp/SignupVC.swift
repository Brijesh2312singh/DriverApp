//
//  SignupVC.swift
//  DriverApp
//
//  Created by Coding Brains on 05/06/26.
//

import UIKit
import Alamofire
struct DriverSignupResponse: Codable {
    let success: Bool
    let message: String
    let driver: SignupDriver?
}

struct SignupDriver: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let car_name: String
    let car_number: String
    let car_color: String?
}
class SignupVC: UIViewController {
    
    @IBOutlet weak var phonenumberTF: UITextField!
    @IBOutlet weak var countryflagImageView: UIImageView!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var phonenumberView: UIView!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var vechielnumberView: UIView!
    @IBOutlet weak var vechielnumberTF: UITextField!
    
    @IBOutlet weak var checkboxBtn: UIButton!
    
    @IBOutlet weak var signupBtn: UIButton!
    
    var isChecked = false
    var isPasswordVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor.gray.cgColor
        emailView.layer.cornerRadius = 10
        
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor.gray.cgColor
        passwordView.layer.cornerRadius = 10
        
        vechielnumberView.layer.borderWidth = 1
        vechielnumberView.layer.borderColor = UIColor.gray.cgColor
        vechielnumberView.layer.cornerRadius = 10
        
        fullnameView.layer.borderWidth = 1
        fullnameView.layer.borderColor = UIColor.gray.cgColor
        fullnameView.layer.cornerRadius = 10
        
        phonenumberView.layer.borderWidth = 1
        phonenumberView.layer.borderColor = UIColor.gray.cgColor
        phonenumberView.layer.cornerRadius = 10
        
        signupBtn.layer.cornerRadius = 10
        
        
    }
    @IBAction func signupTappedBtn(_ sender: UIButton) {
        signupAPI()
    }
    @IBAction func termsandconditionTapped(_ sender: UIButton) {
    }
    @IBAction func eyetapped(_ sender: UIButton) {
        isPasswordVisible.toggle()
        
        passwordTF.isSecureTextEntry = !isPasswordVisible
        
        let icon = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        eyeBtn.setImage(UIImage(systemName: icon), for: .normal)
    }
    @IBAction func checkboxTapped(_ sender: UIButton) {
        isChecked.toggle()
        
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        checkboxBtn.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxBtn.tintColor = isChecked ? .systemGreen : .gray
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Driver Signup",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func showSuccessAndGoLogin(_ message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
            let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    
    func signupAPI() {
        
        let name = fullnameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phonenumberTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let carNumber = vechielnumberTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if name.isEmpty {
            showAlert("Please enter full name")
            return
        }
        
        if email.isEmpty {
            showAlert("Please enter email")
            return
        }
        
        if phone.isEmpty {
            showAlert("Please enter phone number")
            return
        }
        
        if password.isEmpty {
            showAlert("Please enter password")
            return
        }
        
        if carNumber.isEmpty {
            showAlert("Please enter vehicle number")
            return
        }
        
        if !isChecked {
            showAlert("Please accept terms and conditions")
            return
        }
        
        let url = "https://unarmored-dropper-blatantly.ngrok-free.dev/api/drivers/signup"
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let params: [String: Any] = [
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
            "car_name": "Hyundai",
            "car_number": carNumber,
            "car_color": "Red"
        ]
        
        print("SIGNUP PARAMS:", params)
        
        signupBtn.isEnabled = false
        signupBtn.setTitle("Please wait...", for: .normal)
        
        AF.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .responseData { response in
            
            DispatchQueue.main.async {
                self.signupBtn.isEnabled = true
                self.signupBtn.setTitle("Sign Up", for: .normal)
            }
            
            print("SIGNUP STATUS:", response.response?.statusCode ?? 0)
            
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("SIGNUP RAW:", raw)
            }
            
            switch response.result {
                
            case .success(let data):
                
                do {
                    let decoded = try JSONDecoder().decode(
                        DriverSignupResponse.self,
                        from: data
                    )
                    
                    DispatchQueue.main.async {
                        if decoded.success {
                            self.showSuccessAndGoLogin(decoded.message)
                        } else {
                            self.showAlert(decoded.message)
                        }
                    }
                    
                } catch {
                    print("Signup Decode Error:", error)
                    DispatchQueue.main.async {
                        self.showAlert("Invalid server response")
                    }
                }
                
            case .failure(let error):
                print("Signup Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert("Something went wrong")
                }
                
                
                func showAlert(_ message: String) {
                    let alert = UIAlertController(
                        title: "Driver Signup",
                        message: message,
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}
