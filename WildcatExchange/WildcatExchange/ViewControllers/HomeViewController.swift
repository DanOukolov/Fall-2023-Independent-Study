

//
//  HomeViewController.swift
//  WildcatExchange
//
//  Created by Kishan Vyas on 11/7/23.
//
/*


import Foundation
import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Marketplace"
    }
    
}
*/



import Foundation
import UIKit

class HomeViewController: UIViewController {

    // Array to store marketplace items
    var items: [MarketplaceItem] = []

    // UITableView to display items
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Marketplace"

        setupTableView()
        loadSampleData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    private func loadSampleData() {
        guard let url = Bundle.main.url(forResource: "SampleMarketplaceData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Could not find SampleMarketplaceData.json")
            return
        }

        do {
            items = try JSONDecoder().decode([MarketplaceItem].self, from: data)
        } catch {
            print("Error: Could not decode JSON - \(error)")
        }
    }
    

       private func loadMoreData() {
           print("hello")
       }
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.title) - \(item.price)"
        // You can further customize the cell to include more details or custom layout
        return cell
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let item = items[indexPath.row]

            // Clearing old content
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            // Image View
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            // Title Label
            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // Price Label
            let priceLabel = UILabel()
            priceLabel.text = item.price
            priceLabel.translatesAutoresizingMaskIntoConstraints = false

            // Seller Label
            let sellerLabel = UILabel()
            sellerLabel.text = "Seller: \(item.seller.name)"
            sellerLabel.translatesAutoresizingMaskIntoConstraints = false

            // Adding subviews
            cell.contentView.addSubview(imageView)
            cell.contentView.addSubview(titleLabel)
            cell.contentView.addSubview(priceLabel)
            cell.contentView.addSubview(sellerLabel)

            // Constraints
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                imageView.heightAnchor.constraint(equalToConstant: 200),

                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),

                priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                priceLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                priceLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),

                sellerLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
                sellerLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                sellerLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
                sellerLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
            ])

            // Asynchronous Image Loading
            DispatchQueue.global(qos: .userInitiated).async {
                if let url = URL(string: item.imageUrl), let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }

        
            return cell
        }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle item selection - maybe push to a detail view controller
    }
    
    
}




