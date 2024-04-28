import UIKit

enum ModeLoginViewController {
    case createPassword
    case checkPassword
    case changePassword
}

final class LoginViewController: UIViewController {
    
    private let coordinator: MainCoordinator?
    private var mode: ModeLoginViewController
    private lazy var password = ""
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray4
        button.setTitle("Unkoun", for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.addTarget(self, action: #selector(logInButtonPrassed), for: .touchUpInside)
        return button
    }()
 
    init(mode: ModeLoginViewController, coordinator: MainCoordinator?) {
        self.mode = mode
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContraints()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubviews(passwordTextField, logInButton)
        setupLoginButtonTitle()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupContraints() {
        let safeAreaGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -16),
            
            logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            logInButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            logInButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor)
            ])
    }
    
    private func setupLoginButtonTitle() {
        var title: String
        switch mode {
        case .createPassword:
            title = password == "" ? "Create password" : "Confirm password"
        case .checkPassword:
            title = "Log in"
        case .changePassword:
            title = password == "" ? "Create new password" : "Confirm new password"
        }
        logInButton.setTitle(title, for: .normal)
    }
    
    @objc func passwordTextChanged() {
        let resultPassword = passwordTextField.text ?? ""
        logInButton.isEnabled = resultPassword.count > 3
        logInButton.backgroundColor = resultPassword.count > 3 ? .systemMint : .systemGray4
    }
    
    @objc func logInButtonPrassed() {
        switch mode {
        case .createPassword, .changePassword:
            if password == "" {
                password = passwordTextField.text ?? ""
                passwordTextField.text = ""
                passwordTextChanged()
                setupLoginButtonTitle()
            } else {
                if password == passwordTextField.text {
                    KeychainService.default.writePassword(password: password)
                    if mode == .createPassword {
                        navigationController?.pushViewController(coordinator?.openFileManager() ?? UIViewController(), animated: true)
                    } else {
                        dismiss(animated: true)
                    }
                } else {
                    password = ""
                    passwordTextField.text = ""
                    passwordTextChanged()
                    setupLoginButtonTitle()
                    let alertController = UIAlertController(title: "Authorization error", message: "Passwords don't match", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    present(alertController, animated: true)
                }
            }
            case .checkPassword:
            if KeychainService.default.isPasswordCorrect(password: passwordTextField.text!) {
                navigationController?.pushViewController(coordinator?.openFileManager() ?? UIViewController(), animated: true)
            } else {
                passwordTextField.text = ""
                passwordTextChanged()
                let alertController = UIAlertController(title: "Password verification error", message: "Wrong password", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alertController, animated: true)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
