//
//  MainTabBarViewController.swift
//  WildcatExchange
//
//  Created by Anh Hoang on 11/7/23.
//

import Foundation
import UIKit

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeButton"), selectedImage: UIImage(named: "homeIconFilled"))
        
        let chatViewController = ChatViewController()
        chatViewController.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "chatButton"), selectedImage: UIImage(named: "chatIconFilled"))
        
        let userProfileViewController = UserProfileViewController()
        userProfileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileButton"), selectedImage: UIImage(named: "profileIconFilled"))
        
        
        // Assign view controllers to the tab bar
        self.viewControllers = [homeViewController, chatViewController, userProfileViewController].map {
            UINavigationController(rootViewController: $0) // Embed each in a navigation controller
        }
    }
}


