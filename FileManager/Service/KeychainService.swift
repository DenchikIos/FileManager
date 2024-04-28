import Foundation
import KeychainSwift

protocol KeychainServiceProtocol {
    func isPasswordEnabled() -> Bool
    func writePassword(password: String)
    func isPasswordCorrect(password: String) -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    static let `default` = KeychainService()
    private init(){}
    
    func isPasswordEnabled() -> Bool {
        let keychain = KeychainSwift()
        if let _ = keychain.get("myPassword") {
            return true
        } else {
            return false
        }
    }
    
    func writePassword(password: String) {
        let keychain = KeychainSwift()
        keychain.set(password, forKey: "myPassword")
    }
    
    func isPasswordCorrect(password: String) -> Bool {
        let keychain = KeychainSwift()
        if let savedPassword = keychain.get("myPassword") {
            return savedPassword == password
        } else {
            return false
        }
    }
}
