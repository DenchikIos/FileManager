import UIKit

final class MainCoordinator {
    
    private var mainTabBarController: UITabBarController
    
    init() {
        mainTabBarController = UITabBarController()
    }
    
    func start() -> UIViewController {
        setupUserDefaults()
        let mode: ModeLoginViewController = KeychainService.default.isPasswordEnabled() ? .checkPassword : .createPassword
        let loginViewController = LoginViewController(mode: mode, coordinator: self)
        let loginNavigationController = UINavigationController(rootViewController: loginViewController)
        return loginNavigationController
    }
    
    private func setupUserDefaults(){
        if UserDefaults.standard.object(forKey: .sizeFile) == nil {
            UserDefaults.standard.set(true, forKey: .sizeFile)
            UserDefaults.standard.set(true, forKey: .sortingFile)
        }
        Settings.sizeFile = UserDefaults.standard.bool(forKey: .sizeFile)
        Settings.sortingFile = UserDefaults.standard.bool(forKey: .sortingFile)
    }
    
    private func setTabBarController(){
        mainTabBarController.tabBar.backgroundColor = .systemBackground
        mainTabBarController.navigationItem.hidesBackButton = true
        addControllersToTabBar()
    }
    
    private func addControllersToTabBar(){
        mainTabBarController.viewControllers = [createFile(), createSettings()]
    }
    
    func createFile() -> UINavigationController{
        let fileManagerController = FileViewController()
        let fileManagerNavigationController = UINavigationController(rootViewController: fileManagerController)
        fileManagerNavigationController.tabBarItem = UITabBarItem(title: "Documents", image: UIImage(systemName:"doc.circle"), tag: 0)
        return fileManagerNavigationController
    }
    
    func createSettings() -> UINavigationController{
        let settingsController = SettingsViewController()
        let settingsNavigationController = UINavigationController(rootViewController: settingsController)
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        return settingsNavigationController
    }
    
    func openFileManager() -> UIViewController {
        setTabBarController()
        return mainTabBarController
    }
    
}
