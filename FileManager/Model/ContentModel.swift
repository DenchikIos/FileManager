import Foundation

enum TypeOfFile {
    case folder
    case file
}

struct Content {
    let name: String
    let type: TypeOfFile
    let size: String
}
