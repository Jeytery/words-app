//
//  PackagesViewController.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import UIKit
import SnapKit
import Upiter

import MobileCoreServices
import UniformTypeIdentifiers

import AlertKit

protocol PackagesViewControllerDelegate: AnyObject {
    func packagesViewController(
        _ viewController: PackagesViewController,
        didSelect package: WordPackage,
        at index: Int
    )
    
    func packagesViewController(
        _ viewController: PackagesViewController,
        didTapShuffle package: WordPackage,
        at index: Int
    )
}

class PackagesViewController: UIViewController {
        
    weak var delegate: PackagesViewControllerDelegate?
    
    init(packageService: PackageServiceTarget) {
        self.packageService = packageService
        super.init(nibName: nil, bundle: nil)
        
        configureNavigationButtons()
        configureViewController()
        configureTableView()
        configureEmptyLabel()
        
        fetchPackages()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private let packageService: PackageServiceTarget
    private let emptyLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private(set) var packages = WordPackages()
}

// MARK: - public api
extension PackagesViewController {
    func displayPackages(_ packages: WordPackages) {
        self.packages = packages
        self.emptyLabel.alpha = packages.isEmpty ? 1 : 0
        tableView.reloadData()
    }
    
    func addPackage(_ package: WordPackage) {
        self.packages.append(package)
        popEmptyState()
        tableView.insertRows(at: [.init(row: packages.count - 1, section: 0)], with: .automatic)
    }
    
    func deletePackage(at indexPath: IndexPath) {
        self.packages.remove(at: indexPath.row)
        packages.isEmpty ? setEmptyState() : popEmptyState()
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

private extension PackagesViewController {
    func setEmptyState() {
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.emptyLabel.alpha = 1
        })
    }
    
    func popEmptyState() {
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.emptyLabel.alpha = 0
        })
    }
    
    func showActivityController(_ url: URL, completion: @escaping () -> Void) {
        let files: [URL] = [url]
        
        let activityViewController = UIActivityViewController(
            activityItems: files,
            applicationActivities: nil)

        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, error in
            completion()
        }
        
        present(activityViewController, animated: true)
    }
    
    func showRightNavigationButtonAlert() {
        let alert = UIAlertController(
            title: "Type package name",
            message: "",
            preferredStyle: .alert
        )
        alert.addTextField {
            textField in
            textField.placeholder = "Package's name"
        }
        alert.addAction(
            .init(title: "Cancel", style: .cancel) { _ in }
        )
        alert.addAction(
            .init(title: "Add", style: .default) {
                [unowned self] _ in
                let tf = alert.textFields![0]
                guard let text = tf.text, !text.isEmpty else {
                    AlertKitAPI.present(title: "Empty name", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .error)
                    return
                }
                let package = WordPackage(name: text, words: [])
                self.addPackage(package)
                self.packageService.savePackages(self.packages, errorHandler: nil)
            }
        )
        present(alert, animated: true, completion: nil)
    }
    
    func fetchPackages() {
        packageService.getPackages {
            [unowned self] result in
            switch result {
            case .success(let _packages):
                self.displayPackages(_packages)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func showErrorAlert(title: String, title2: String?) {
        let alert = UIAlertController(
            title: title,
            message: title2,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(title: "Ok", style: .default) { _ in }
        )
        present(alert, animated: true, completion: nil)
    }
}

private extension PackagesViewController {
    func configureViewController() {
        tabBarItem = .init(
            title: "Words",
            image: UIImage(systemName: "square.stack.fill"),
            selectedImage: nil
        )
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    func configureEmptyLabel() {
        emptyLabel.text = "No packages..."
        emptyLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        emptyLabel.tintColor = .secondaryLabel
        emptyLabel.alpha = 0 
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints() {
            $0.center.equalToSuperview()
        }
    }
}

extension PackagesViewController {
    @objc func importDidTap() {
        let types = UTType.types(
            tag: "txt",
            tagClass: UTTagClass.filenameExtension,
            conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
            forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    @objc func addDidTap() {
        self.showRightNavigationButtonAlert()
    }
    
    private func configureNavigationButtons() {
        let add = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addDidTap)
        )
        let _import = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down")!,
            style: .plain,
            target: self,
            action: #selector(importDidTap))

        navigationItem.rightBarButtonItems = [add, _import]
    }
}

extension PackagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath)
        cell.textLabel?.text = packages[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return packages.count
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return "Tap + to create new package of your words. Swipe LEFT <-- to edit"
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.packagesViewController(
            self,
            didSelect: packages[indexPath.row],
            at: indexPath.row
        )
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) {
            [unowned self] contextualAction, view, boolValue in
            self.deletePackage(at: indexPath)
            self.packageService.savePackages(self.packages, errorHandler: nil)
        }
        
        let shuffle = UIContextualAction(
            style: .normal,
            title: "Shuffle"
        ) {
            [unowned self] contextualAction, view, boolValue in
            self.delegate?.packagesViewController(
                self,
                didTapShuffle: packages[indexPath.row],
                at: indexPath.row
            )
        }
        
        let share = UIContextualAction(
            style: .normal,
            title: "Share"
        ) {
            [unowned self] contextualAction, view, boolValue in
            let backupService = BackupService(for: self.packages[indexPath.row])
            let result = backupService.backup()

            switch result {
            case .success(let url):
                self.showActivityController(url) {
                    if let error = backupService.removeFile() {
                        print(error)
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
        
        share.backgroundColor = .systemGreen
        shuffle.backgroundColor = .systemPurple
       
        return UISwipeActionsConfiguration(actions: [shuffle, share, delete])
    }
}

extension PackagesViewController {
    func updatePackage(_ package: WordPackage, at index: Int) {
        packages.remove(at: index)
        packages.insert(package, at: index)
        tableView.reloadData()
        packageService.savePackages(packages, errorHandler: nil)
    }
}

extension PackagesViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else {
            self.showErrorAlert(title: "Wrong File", title2: nil)
            return print("documentPicker.didPickDocumentsAt: no url")
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            self.showErrorAlert(title: "Wrong File", title2: nil)
            return
        }
        
        do {
            let jsonString = try String(contentsOf: url, encoding: .utf8)
            
            guard let packageData = jsonString.data(using: .utf8) else {
                self.showErrorAlert(title: "Wrong File", title2: nil)
                return print("documentPicker.didPickDocumentsAt: packageData is nil")
            }
            
            guard let package = WordPackage.unarchive(data: packageData) else {
                self.showErrorAlert(title: "Wrong File", title2: nil)
                return
            }
            self.addPackage(package)
            url.stopAccessingSecurityScopedResource()
        }
        catch(let error) {
            print(error)
            self.showErrorAlert(title: "Wrong File", title2: nil)
            url.stopAccessingSecurityScopedResource()
        }
    }
}
