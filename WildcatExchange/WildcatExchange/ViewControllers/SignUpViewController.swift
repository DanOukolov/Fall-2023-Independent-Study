//
//  SignUpViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 10/26/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI



class SignUpViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SIGN UP"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    

    
    private let nameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let phoneField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let confirmPasswordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    
    
    @objc private func didTapSignUpButton() {
        guard let email = emailField.text, isValidEmail(email), let password = passwordField.text else {
            // Show an alert or message to the user
            let alert = UIAlertController(title: "Invalid Email", message: "Please use an email ending with @davidson.edu", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let displayName = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let phoneNum = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            // Handle the error: One or more text fields are empty or invalid
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.presentAlert(title: "Error", message: "Unable to get user information.")
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { (error) in
                if let error = error {
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                self.saveUserInfoToFirestore(userId: user.uid, name: displayName, email: email, phoneNum: phoneNum)
                
                user.sendEmailVerification { (error) in
                    if let error = error {
                        print("Error sending verification email: \(error.localizedDescription)")
                        self.presentAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self.presentAlert(title: "Verification Email Sent", message: "Please check your email and verify your account.")
                    }
                }
                
                // Navigate to the sign in screen
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        return email.hasSuffix("@davidson.edu")
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveUserInfoToFirestore(userId: String, name: String, email: String, phoneNum: String) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "phoneNum": phoneNum,
            "profilePictureURL": "https://firebasestorage.googleapis.com/v0/b/ios-dev-b80ed.appspot.com/o/blank-profile-picture-973460_1280.png?alt=media&token=e9a0a083-fa9c-4eb9-afa6-6c67da7b50ae"
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error saving user data to Firestore: \(error)")
                return
            }
            print("User data saved to Firestore with a blank profile picture.")
        }
    }
    
    
    
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameField)
        view.addSubview(phoneField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(signUpButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            phoneField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            phoneField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailField.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 20),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            confirmPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 20),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
