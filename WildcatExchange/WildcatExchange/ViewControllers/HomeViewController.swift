//
//  HomeViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/7/23.
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
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.title) - \(item.price)"
        // You can further customize the cell to include more details or custom layout
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle item selection - maybe push to a detail view controller
    }
}



