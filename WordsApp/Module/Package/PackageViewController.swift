//
//  PackageViewController.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import Foundation
import UIKit
import SnapKit
import NavigationButtonable
import UniformTypeIdentifiers
import AlertKit
import SwiftUI

protocol PackageViewControllerDelegate: AnyObject {
    func packageViewController(
        _ viewController: PackageViewController,
        didReturn package: WordPackage
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didDelete package: WordPackage
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didAdd word: Word
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didChangedPackageName name: String
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didTapShareWith package: WordPackage
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didTapShuffleWith package: WordPackage
    )
    func packageViewController(
        _ viewController: PackageViewController,
        didTapReverseShuffleWith package: WordPackage
    )
}

extension PackageViewControllerDelegate {
    func packageViewController(
        _ viewController: PackageViewController,
        didDelete package: WordPackage
    ) {}
     
    func packageViewController(
        _ viewController: PackageViewController,
        didAdd word: Word
    ) {}
     
    func packageViewController(
        _ viewController: PackageViewController,
        didChangedPackageName name: String
    ) {}
    
    func packageViewController(
        _ viewController: PackageViewController,
        didTapShareWith package: WordPackage
    ){}
    
    func packageViewController(
        _ viewController: PackageViewController,
        didTapShuffleWith package: WordPackage
    ){}
    
    func packageViewController(
        _ viewController: PackageViewController,
        didTapReverseShuffleWith package: WordPackage
    ){}
}

class PackageViewController: UIViewController {
    
    weak var delegate: PackageViewControllerDelegate?
    
    private var headerTitleState = HeaderChangePackageNameCellViewState()
    
    private lazy var header: InsetGroupedSectionView = { [self] in
        let view = UIHostingController(
            rootView: HeaderChangePackageNameCellView(state: headerTitleState)
        ).view ?? UIView()
        view.backgroundColor = .clear
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "PACKAGE NAME"
        label.textColor = .secondaryLabel
        let label2 = UILabel()
        label2.font = .systemFont(ofSize: 14, weight: .regular)
        label2.text = "WORDS"
        label2.textColor = .secondaryLabel
        
        
        let view3 = UIHostingController(rootView: LightButton2.init(title: "Shuffle", imageName: "shuffle", color: .purple, action: {})).view!
        view3.backgroundColor = .clear
        let view4 = UIHostingController(rootView: LightButton2.init(title: "Reverse shuffle", imageName: "shuffle", color: .orange, action: {})).view!
        view4.backgroundColor = .clear
      
        return InsetGroupedSectionView(
            data: .init(
                cells: [
                    .init(
                        view: view,
                        height: 46,
                        insets: .init(top: 0, left: 20, bottom: 0, right: 20),
                        didTap: {
                            [weak self] in
                            guard let self = self else {
                                return
                            }
                            let alert = UIAlertController(
                                title: "Enter new package name",
                                message: "",
                                preferredStyle: .alert
                            )
                            alert.addTextField {
                                tf in
                                tf.placeholder = "Package name"
                            }
                            alert.addAction(
                                .init(title: "Cancel", style: .cancel) { _ in }
                            )
                            alert.addAction(
                                .init(title: "Add", style: .default) {_ in 
                                    guard
                                        let firstTitle = alert.textFields![0].text,
                                        !firstTitle.isEmpty
                                    else {
                                        AlertKitAPI.present(title: "Name is empty", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .error)
                                        return
                                    }
                                    self.headerTitleState.titleToChange = firstTitle
                                    self.package.name = firstTitle
                                    self.delegate?.packageViewController(self, didChangedPackageName: firstTitle)
                                }
                            )
                            present(alert, animated: true, completion: nil)
                        }),
                    .init(
                        view: view3,
                        height: 46,
                        insets: .init(top: 0, left: 20, bottom: 0, right: 20),
                        didTap: { [weak self] in
                            guard let self = self else { return }
                            self.delegate?.packageViewController(self, didTapShuffleWith: self.package)
                        }),
                    .init(
                        view: view4,
                        height: 46,
                        insets: .init(top: 0, left: 20, bottom: 0, right: 20),
                        didTap: { [weak self] in
                            guard let self = self else { return }
                            self.delegate?.packageViewController(self, didTapReverseShuffleWith: self.package)
                        })
                ],
                header: .init(view: UIView(), height: 0),
                footer: .init(view: label2, height: 22)
            )
        )
    }()
    
    private lazy var headerContainer: UIView = {
        let _view = UIView()
        _view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: _view.topAnchor),
            header.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            header.rightAnchor.constraint(equalTo: _view.rightAnchor, constant: 0),
            header.leftAnchor.constraint(equalTo: _view.leftAnchor, constant: 0),
        ])
        return _view
    }()
    
    init(package: WordPackage = .empty) {
        self.package = package
        super.init(nibName: nil, bundle: nil)
        self.headerTitleState.titleToChange = package.name
        view.backgroundColor = .systemBackground
        self.navigationItem.largeTitleDisplayMode = .never
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DoubleTitleTableViewCell.self, forCellReuseIdentifier: "cell")

        /* title = package.name */
        /* configureRightNavigationButton() */
        
        configureNavigationButtons()
        
        emptyLabel.text = "No words..."
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(100)
        }
        emptyLabel.alpha = 0
        emptyLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        emptyLabel.textColor = .secondaryLabel
        
        setStatus(package.words.isEmpty)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /* delegate?.packageViewController(self, didReturn: package) */
    }
    
    private(set) var package: WordPackage
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel = UILabel()
}

private extension PackageViewController {
    func configureNavigationButtons() {
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(trashButtonTapped)
        )
        trashButton.tintColor = .systemRed
        let plusButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(plusButtonTapped)
        )
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        navigationItem.rightBarButtonItems = [plusButton, shareButton, trashButton]
    }
    
    @objc private func shareButtonTapped() {
        delegate?.packageViewController(self, didTapShareWith: self.package)
    }
    
    @objc private func trashButtonTapped() {
        delegate?.packageViewController(self, didDelete: self.package)
    }
    
    @objc private func plusButtonTapped() {
        addNewWordDidTap()
    }
    
    func addWord(_ word: Word) {
        self.package.words.append(word)
        tableView.insertRows(at: [.init(row: self.package.words.count - 1, section: 0)], with: .automatic)
        popEmptyState()
    }
    
    func deleteWord(at indexPath: IndexPath) {
        self.package.words.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if package.words.isEmpty {
            setEmptyState()
        }
    }
    
    func setStatus(_ isEmpty: Bool) {
        isEmpty ? setEmptyState() : popEmptyState()
    }
    
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
    
    func addNewWordDidTap() {
        let alert = UIAlertController(
            title: "Add new word",
            message: "",
            preferredStyle: .alert
        )
        alert.addTextField {
            tf in
            tf.placeholder = "Word"
        }
        alert.addTextField {
            tf in
            tf.placeholder = "Translation"
        }
        alert.addAction(
            .init(title: "Cancel", style: .cancel) { _ in }
        )
        alert.addAction(
            .init(title: "Add", style: .default) {
                [unowned self] _ in
                guard
                    let firstTitle = alert.textFields![0].text,
                    !firstTitle.isEmpty
                else {
                    AlertKitAPI.present(title: "Word is empty", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .error)
                    return
                }
                guard
                    let secondTitle = alert.textFields![1].text,
                    !secondTitle.isEmpty
                else {
                    AlertKitAPI.present(title: "Translation is empty", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .error)
                    return
                }
                let word = Word(firstTitle: firstTitle, secondTitle: secondTitle, rating: 0)
                self.addWord(word)
                self.delegate?.packageViewController(self, didAdd: word)
            }
        )
        present(alert, animated: true, completion: nil)
    }
}

extension PackageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerContainer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return header.dynamicHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath) as! DoubleTitleTableViewCell
        cell.textLabel?.text = package.words[indexPath.row].firstTitle
        cell.detailTextLabel?.text = package.words[indexPath.row].secondTitle
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return package.words.count
    }
   
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        deleteWord(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return "Tap + to add new words"
    }
}
