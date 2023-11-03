//
//  UserProfileViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/2/23.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome User!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    @objc private func didTapLogoutButton() {
        do {
            try Auth.auth().signOut()
            let signInVC = SignInViewController()
            let navigationController = UINavigationController(rootViewController: signInVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        } catch let error {
            print("Failed to sign out with error:", error.localizedDescription)
        }
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        view.addSubview(logoutButton)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            logoutButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
}

