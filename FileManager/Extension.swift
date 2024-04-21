import UIKit

extension String {
    static let sortingFile = "Sorting file"
    static let sizeFile = "Size file"
}

struct Settings {
    static var sortingFile = true
    static var sizeFile = true
    private init(){}
}

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for i in subviews {
            self.addSubview(i)
        }
    }
}
