//
//  HomeViewController.swift
//  WildcatExchange
//
//  Created by Kishan Vyas on 11/7/23.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    private var products = [Product]()
    private let tableView = UITableView()
    private var listener: ListenerRegistration?
    
    
    
    
    private func setupAddListingButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListingTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addListingTapped() {
        let addListingVC = AddListingViewController()
        navigationController?.pushViewController(addListingVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Marketplace"
        setupTableView()
        setupAddListingButton()
        listenForProducts()
    }
    
    deinit {
        listener?.remove()
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: ProductTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func confirmAndDeleteProduct(_ product: Product, at indexPath: IndexPath) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in")
            return
        }
        
        if currentUserId != product.userId {
            print("You can only delete your own products.")
            return
        }
        
        let alert = UIAlertController(title: "Delete Product", message: "Are you sure you want to delete this product?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteProduct(product, at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productToDelete = products[indexPath.row]
            confirmAndDeleteProduct(productToDelete, at: indexPath)
        }
    }
    
    
    private func deleteProduct(_ product: Product, at indexPath: IndexPath) {
        let db = Firestore.firestore()
        db.collection("products").document(product.id).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error deleting product: \(error)")
            } else {
                // Check if the index is valid before removing the product
                if indexPath.row < self.products.count {
                    self.products.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }

                // Refresh products from Firestore
                self.listenForProducts()
            }
        }
    }


    
    
    
    private func listenForProducts() {
        let db = Firestore.firestore()
        listener = db.collection("products").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.products = querySnapshot?.documents.compactMap { document -> Product? in
                let data = document.data()
                guard
                    let id = data["id"] as? String,
                    let userId = data["userId"] as? String,
                    let userName = data["userName"] as? String,
                    let name = data["productName"] as? String,
                    let description = data["description"] as? String,
                    let price = data["price"] as? Double,
                    let imageURL = data["imageURL"] as? String,
                    let userProfileURL = data["userProfileURL"] as? String,
                    let timestamp = data["date"] as? Timestamp
                else {
                    return nil
                }
                let date = timestamp.dateValue()
                return Product(id: id, userId: userId, userName: userName,  userProfileURL: userProfileURL, productName: name,  description: description, price: price, imageURL: imageURL, date: date)
            } ?? []
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func fetchProducts() {
        let db = Firestore.firestore()
        db.collection("products").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.products = querySnapshot?.documents.compactMap { document -> Product? in
                let data = document.data()
                guard
                    let id = data["id"] as? String,
                    let userId = data["userId"] as? String,
                    let userName = data["userName"] as? String,
                    let name = data["productName"] as? String,
                    let description = data["description"] as? String,
                    let price = data["price"] as? Double,
                    let imageURL = data["imageURL"] as? String,
                    let userProfileURL = data["userProfileURL"] as? String,
                    let timestamp = data["date"] as? Timestamp
                else {
                    return nil
                }
                
                let date = timestamp.dateValue()
                return Product(id: id, userId: userId, userName: userName, userProfileURL: userProfileURL, productName: name, description: description, price: price, imageURL: imageURL, date: date)
            } ?? []
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        cell.configure(with: product)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.contentView.addInteraction(interaction)
        
        
        cell.menuButtonAction = { [weak self] in
            guard let self = self else { return }
            let product = self.products[indexPath.row]
            self.presentMenu(for: product, at: indexPath)
        }
        
        return cell
    }
    
    private func presentMenu(for product: Product, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Edit action
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.editProduct(product, at: indexPath)
        }
        alertController.addAction(editAction)
        
        // Delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmAndDeleteProduct(product, at: indexPath)
        }
        alertController.addAction(deleteAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    private func editProduct(_ product: Product, at indexPath: IndexPath) {
        let editVC = EditLisitingViewController()
        editVC.productToEdit = product
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    
}

extension HomeViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = tableView.indexPathForRow(at: location),
              let cell = tableView.cellForRow(at: indexPath) as? ProductTableViewCell else {
            return nil
        }
        
        let product = products[indexPath.row]
        
        guard let currentUserId = Auth.auth().currentUser?.uid, currentUserId == product.userId else {
            return nil
        }
        
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.editProduct(product, at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.confirmAndDeleteProduct(product, at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
}



