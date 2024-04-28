import UIKit

final class SettingsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        setupUI()
        setupContraints()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        let switchView = UISwitch(frame: .zero)
        cell.accessoryView = switchView
        if indexPath.row == 0 {
            switchView.isOn = UserDefaults.standard.bool(forKey: .sortingFile)
            switchView.addTarget(self, action: #selector(switchSortChanged(_:)), for: .valueChanged)
            content.text = .sortingFile
            cell.selectionStyle = .none
        } else if indexPath.row == 1 {
            switchView.isOn = UserDefaults.standard.bool(forKey: .sizeFile)
            switchView.addTarget(self, action: #selector(switchSortChanged(_:)), for: .valueChanged)
            content.text = .sizeFile
        } else {
            content.text = "Change password"
            cell.accessoryView = .none
        }
        switchView.tag = indexPath.row
        
        cell.selectionStyle = .none
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func switchSortChanged(_ sender : UISwitch!) {
        let settingName: String = sender.tag == 0 ? .sortingFile : .sizeFile
        UserDefaults.standard.set(sender.isOn, forKey: settingName)
        Settings.sizeFile = UserDefaults.standard.bool(forKey: .sizeFile)
        Settings.sortingFile = UserDefaults.standard.bool(forKey: .sortingFile)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let viewControler = LoginViewController(mode: .changePassword, coordinator: nil)
            present(viewControler, animated: true)
        }
    }
}
