//
//  StartVC.swift
//  DriverApp
//
//  Created by Coding Brains on 05/06/26.
//

import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        selectLogin()
       
    }
    func setupButtons() {

        signupBtn.layer.cornerRadius = 10
        signupBtn.layer.borderWidth = 1
        signupBtn.layer.borderColor = UIColor.systemGreen.cgColor

        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.borderColor = UIColor.systemGreen.cgColor
    }
    func selectLogin() {

        loginBtn.backgroundColor = .systemGreen
        loginBtn.setTitleColor(.white, for: .normal)

        signupBtn.backgroundColor = .white
        signupBtn.setTitleColor(.systemGreen, for: .normal)
    }
    func selectSignup() {

        signupBtn.backgroundColor = .systemGreen
        signupBtn.setTitleColor(.white, for: .normal)

        loginBtn.backgroundColor = .white
        loginBtn.setTitleColor(.systemGreen, for: .normal)
    }
    @IBAction func signupTapped(_ sender: UIButton) {
        selectSignup()
        let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "StartVC") as! StartVC

            navigationController?.pushViewController(vc, animated: true)
                return
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        selectLogin()
        let token = UserDefaults.standard.string(forKey: "driverAuthToken") ?? ""
            
            if token.isEmpty {
                let newVC = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(newVC, animated: true)
            } else {
                let newVC = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "DriverHomeVC") as! DriverHomeVC
                self.navigationController?.pushViewController(newVC, animated: true)
            }
    }
    
    @IBAction func termsandconditionBtn(_ sender: UIButton) {
    }
    
    @IBAction func privacyandpolicyTapped(_ sender: UIButton) {
    }
    
}
