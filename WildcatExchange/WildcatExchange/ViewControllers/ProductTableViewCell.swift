//
//  ProductTableViewCell.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/15/23.
//
import UIKit
import SDWebImage


class ProductTableViewCell: UITableViewCell {
    static let identifier = "ProductTableViewCell"
    var menuButtonAction: (() -> Void)?
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemBlue
        return label
    }()
    
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "changePostButton"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    @objc private func menuButtonTapped() {
        menuButtonAction?()
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(productImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(menuButton)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        applyConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            productImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            menuButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            menuButton.widthAnchor.constraint(equalToConstant: 30),
            menuButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    
    public func configure(with product: Product) {
        nameLabel.text = product.productName
        descriptionLabel.text = product.description
        priceLabel.text = "$\(product.price)"
        dateLabel.text = "Posted on: \(formatDate(product.date))"
        usernameLabel.text = product.userName
        if let url = URL(string: product.userProfileURL) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderProfile"))
        }
        
        if let imageUrl = URL(string: product.imageURL) {
            loadImage(from: imageUrl)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func loadImage(from url: URL) {
        productImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        
    }
}
