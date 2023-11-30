//
//  EditLisitingViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/30/23.
//

import Firebase
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import SDWebImage


class EditLisitingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var productToEdit: Product?
    private var isImageChanged = false
    
    
    
    private let nameTextField: UITextField = createTextField(placeholder: "Product Name")
    private let descriptionTextField: UITextField = createTextField(placeholder: "Description")
    private let priceTextField: UITextField = createTextField(placeholder: "Price")
    private let uploadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Image", for: .normal)
        return button
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Listing", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private static func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        return textField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadProductData()
        setupUI()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            isImageChanged = true
        } else {
            showAlert(title: "Error", message: "There was an issue selecting the image.")
        }
    }
    
    
    
    private func loadProductData() {
        guard let product = productToEdit else { return }
        nameTextField.text = product.productName
        descriptionTextField.text = product.description
        priceTextField.text = "\(product.price)"
        
        if !product.imageURL.isEmpty, let imageUrl = URL(string: product.imageURL) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        } else {
            imageView.image = UIImage(named: "placeholderImage") // Fallback placeholder image
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, descriptionTextField, priceTextField, uploadImageButton, imageView, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        uploadImageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        uploadImageButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveListingTapped), for: .touchUpInside)
    }
    
    
    @objc private func uploadImageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @objc private func saveListingTapped() {
        guard let product = productToEdit,
              let name = nameTextField.text, !name.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty,
              let priceText = priceTextField.text, !priceText.isEmpty, let price = Double(priceText) else {
            showAlert(title: "Missing Information", message: "Please fill in all fields.")
            return
        }
        
        let updatedProduct = Product(id: product.id, userId: product.userId, userName: product.userName, userProfileURL: product.userProfileURL, productName: name, description: description, price: price, imageURL: product.imageURL, date: product.date)
        
        if isImageChanged, let newImage = imageView.image {
            uploadImage(newImage) { [weak self] imageUrl in
                guard let imageUrl = imageUrl else {
                    self?.showAlert(title: "Upload Failed", message: "Failed to upload the image. Please try again.")
                    return
                }
                
                let updatedProduct = Product(id: product.id, userId: product.userId, userName: product.userName, userProfileURL: product.userProfileURL, productName: name, description: description, price: price, imageURL: imageUrl, date: product.date)
                self?.updateProductInFirestore(updatedProduct, with: imageUrl)
            }
        } else {
            let updatedProduct = Product(id: product.id, userId: product.userId, userName: product.userName, userProfileURL: product.userProfileURL, productName: name, description: description, price: price, imageURL: product.imageURL, date: product.date)
            updateProductInFirestore(updatedProduct, with: nil)
        }
    }
    
    private func updateProductInFirestore(_ product: Product, with imageUrl: String?) {
        var updatedData: [String: Any] = [
            "productName": product.productName,
            "description": product.description,
            "price": product.price,
            "imageURL": product.imageURL,
            "date": Timestamp(date: product.date)
        ]
        
        if let imageUrl = imageUrl {
            updatedData["imageURL"] = imageUrl
        }
        
        let db = Firestore.firestore()
        db.collection("products").document(product.id).updateData(updatedData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to update product: \(error.localizedDescription)")
            } else {
                self?.showAlert(title: "Success", message: "Product updated successfully") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
    
}

