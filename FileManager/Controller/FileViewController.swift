import UIKit

final class FileViewController: UIViewController {
    
    private let fileManagerService: FileManagerServiceProtocol
    private var contentFolder = [Content]()
    private let currentFolder: String
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var addFolderButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFile))
    private lazy var addImageButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(addFolder))

    init() {
        fileManagerService = FileManagerService()
        currentFolder = "Documents"
        super.init(nibName: nil, bundle: nil)
    }
    
    init(fileManagerService: FileManagerService, currentFolder: String) {
        self.fileManagerService = fileManagerService
        self.currentFolder = currentFolder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentFolder = fileManagerService.contentsOfDirectory()
        setupUI()
        setupContraints()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        title = currentFolder
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [addFolderButton, addImageButton]
        view.addSubview(tableView)
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func addFolder() {
        let alert = UIAlertController(title: "Create new folder", message: nil, preferredStyle: .alert)
        alert.addTextField{ (textField) in
            textField.placeholder = "Folder name"
        }
        let create = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let textField = alert.textFields![0]
            if textField.text != "" {
                self.fileManagerService.createDirectory(name: textField.text!)
                self.contentFolder = self.fileManagerService.contentsOfDirectory()
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: "Name is empty", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alertController, animated: true)

            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(create)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func addFile() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
}

extension FileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = contentFolder[indexPath.row].name
        content.image = UIImage(named: contentFolder[indexPath.row].name)
        if contentFolder[indexPath.row].type == .folder {
            cell.accessoryType = .disclosureIndicator
        } else {
            if Settings.sizeFile {
                content.secondaryText = contentFolder[indexPath.row].size + " " + fileManagerService.getCreationDate(contentFolder[indexPath.row].name)
            }
            cell.accessoryType =  .none
            cell.isUserInteractionEnabled = true
        }
        cell.contentConfiguration = content
        return cell

    }
}

extension FileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = contentFolder[indexPath.row].name
        let fileManagerService = FileManagerService(pathForFolder: self.fileManagerService.getPath(name: name) )
        let nextFileViewController = FileViewController(fileManagerService: fileManagerService, currentFolder: name)
        navigationController?.pushViewController(nextFileViewController, animated: true)
        tableView.largeContentImage = UIImage(named: contentFolder[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fileManagerService.removeContent(name: contentFolder[indexPath.row].name)
            contentFolder = fileManagerService.contentsOfDirectory()
            tableView.reloadData()
        }
    }

}

extension FileViewController:  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        let alert = UIAlertController(title: "Name for image", message: nil, preferredStyle: .alert)
        alert.addTextField{ (textField) in
            textField.placeholder = "Image name"
        }
        let create = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let textField = alert.textFields![0]
            if textField.text != "" {
                self.fileManagerService.createFile(imageURL: info[.imageURL] as! NSURL, fileName: textField.text!)
                self.contentFolder = self.fileManagerService.contentsOfDirectory()
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: "Name is empty", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alertController, animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(create)
        alert.addAction(cancel)
        self.present(alert, animated: true)

    }
}
