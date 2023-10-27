import UIKit

class SignInViewController: UIViewController {
    
    private let topImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFill
           return imageView
    }()
    
    private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "WILDCAT EXCHANGE"
            label.textColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            return label
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Wildcat Exchange, where Wildcats connect, buy, and sell with ease and trust!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let inputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number or Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don’t have an account yet? Sign Up", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    @objc private func didTapSignUpButton() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(topImageView)
        view.addSubview(titleLabel)
        view.addSubview(welcomeLabel)
        view.addSubview(inputField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        topImageView.image = UIImage(named: "loginPic")


        // Set up auto layout
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),
            
            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            welcomeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            inputField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 30),
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputField.heightAnchor.constraint(equalToConstant: 44),
            
            signInButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 20),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

