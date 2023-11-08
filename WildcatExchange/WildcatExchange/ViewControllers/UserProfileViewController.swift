//
//  UserProfileViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/2/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import PhotosUI

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let editNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .gray
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
    
    private let changeProfilePicButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Picture", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        return button
    }()
    
    @objc private func didTapProfileImageView() {
        // Present the image picker
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            self.uploadProfileImage(image)
        }
    }
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists,
                  let userData = document.data() else {
                print("Document does not exist")
                return
            }
            
            self.nameLabel.text = userData["name"] as? String
            self.emailLabel.text = userData["email"] as? String
            
            if let profilePicUrl = userData["profilePictureURL"] as? String, let url = URL(string: profilePicUrl) {
                profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfilePic"), options: [], completed: nil)
            } else {
                profileImageView.image = UIImage(named: "defaultProfilePic")
            }
            
            
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.4), let userId = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference(withPath: "user/\(userId)/profile.jpg")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { [weak self] (downloadMetadata, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else { return }
                self.updateUserProfilePictureURL(url.absoluteString)
            }
        }
    }
    
    private func updateUserProfilePictureURL(_ url: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData(["profilePictureURL": url]) { error in
            if let error = error {
                print("Error updating profile picture URL: \(error.localizedDescription)")
            } else {
                print("Profile picture URL successfully updated")
            }
        }
    }

    
    @objc private func didTapChangeProfilePicButton() {
        didTapProfileImageView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        editNameButton.addTarget(self, action: #selector(didTapEditNameButton), for: .touchUpInside)
        changeProfilePicButton.addTarget(self, action: #selector(didTapChangeProfilePicButton), for: .touchUpInside)
    }
    
    @objc private func didTapEditNameButton() {
        let alertController = UIAlertController(title: "Edit Name", message: "Enter your new name", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.nameLabel.text
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newName = alertController.textFields?.first?.text, !newName.isEmpty, let self = self else { return }
            self.updateNameInFirestore(newName: newName)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    private func updateNameInFirestore(newName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData(["name": newName]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error updating name: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Update Failed", message: "There was an error updating your name: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.nameLabel.text = newName
                }
            }
        }
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
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        view.addSubview(editNameButton)
        view.addSubview(changeProfilePicButton)
        
        
        
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        changeProfilePicButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeProfilePicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeProfilePicButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            changeProfilePicButton.widthAnchor.constraint(equalToConstant: 200),
            changeProfilePicButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: changeProfilePicButton.bottomAnchor, constant: 20)
        ])
        
        editNameButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editNameButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editNameButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            editNameButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
}




