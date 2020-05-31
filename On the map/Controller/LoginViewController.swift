//
//  LoginViewController.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var signUpTextView: UITextView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var preloader: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    let linkUrl = "https://auth.udacity.com/sign-up"
    let accountPart = "Don't have an account?"
    let signUpPart = "Sign up"
    
    var apiClient : ApiClient  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.apiClient
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        signUpTextView.hyperLink(originalText: "\(accountPart) \(signUpPart)", hyperLink:signUpPart , urlString: linkUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        togglePreloader(isVisible: false)
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == linkUrl) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return false
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        let username = userNameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        togglePreloader(isVisible: true)
        
        apiClient.login(username: username, password: password, result: { (student, error) in
            
            
            DispatchQueue.main.async {
                
                self.togglePreloader(isVisible: false)
                if (error == nil) {
                    let object = UIApplication.shared.delegate
                    let appDelegate = object as! AppDelegate
                    appDelegate.student = student
                    self.navigateToNextScreen()
                } else {
                    self.showAlert(alertMessage: self.apiClient.getAlertDataFromError(error: error!), buttonTitle: "Ok")
                }
                
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.tag == 11) {
            loginTapped(textField)
        }
        return true
    }
    
    func togglePreloader(isVisible: Bool) {
        preloader.isHidden = !isVisible
        submitButton.isEnabled = !isVisible
    }
    
    func navigateToNextScreen() {
        let detailController = storyboard?.instantiateViewController(withIdentifier: "studentPlacesTabController") as! UITabBarController
        detailController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        navigationController?.showDetailViewController(detailController, sender: self)
    }
}
