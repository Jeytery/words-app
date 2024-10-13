//
//  MainCoordinator.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import UIKit
import AlertKit
import SwiftUI
class MainCoordinator {
    private(set) var navigationPresenter = UINavigationController()
    private var currentPackageIndex: Int = 0
    
    init() {
        navigationPresenter.setViewControllers([packagesViewController], animated: false)
        packagesViewController.delegate = self
    }
    
    private let packagesViewController = PackagesViewController.module()
    private let packageService = PackageService()
}

extension MainCoordinator: PackagesViewControllerDelegate {
    func packagesViewControllerDidTapSettings(_ viewController: PackagesViewController) {
        let settingsViewController = UIHostingController(rootView: SettingsView())
        let navigation = ClosableNavigationController(rootViewController: settingsViewController).onlyFirst()
        navigation.modalPresentationStyle = .overFullScreen
        navigationPresenter.present(navigation, animated: true)
    }
    
    func packagesViewController(
        _ viewController: PackagesViewController,
        didTapShuffle package: WordPackage,
        at index: Int
    ) {
        if package.words.isEmpty {
            let alert = UIAlertController(title: "Error", message: "No words in package", preferredStyle: .alert)
            alert.addAction(.init(title: "Okay", style: .default) { _ in })
            navigationPresenter.present(alert, animated: true, completion: nil)
            return
        }
        let vc = CardStackViewController(cardContents: package.cardContentShufled)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        navigationPresenter.present(nvc, animated: true, completion: nil)
    }
    
    func packagesViewController(_ viewController: PackagesViewController, didTapReverseShuffle package: WordPackage, at index: Int) {
        if package.words.isEmpty {
            let alert = UIAlertController(title: "No words in package", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Okay", style: .default) { _ in })
            navigationPresenter.present(alert, animated: true, completion: nil)
            return
        }
        let vc = CardStackViewController(
            cardContents: package.words
                .map({
                    return CardContent(firstTitle: $0.secondTitle, secondTitle: $0.firstTitle)
                })
                .shuffled()
        )
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        navigationPresenter.present(nvc, animated: true, completion: nil)
    }
    
    func packagesViewController(
        _ viewController: PackagesViewController,
        didSelect package: WordPackage,
        at index: Int
    ) {
        let vc = PackageViewController(package: package)
        vc.delegate = self
        currentPackageIndex = index
        navigationPresenter.pushViewController(vc, animated: true)
    }
    
    func showAlert(title: String, title2: String?, action: (() -> Void)?) {
        let alert = UIAlertController(
            title: title,
            message: title2,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(title: "Cancel", style: .default) { _ in }
        )
        alert.addAction(
            .init(title: "Ok", style: .default) { _ in action?() }
        )
        navigationPresenter.present(alert, animated: true, completion: nil)
    }
}

// MARK: - PackageViewController delegate
extension MainCoordinator: PackageViewControllerDelegate {
    
    func packageViewController(
        _ viewController: PackageViewController,
        didReturn package: WordPackage
    ) {
        packagesViewController.updatePackage(package, at: currentPackageIndex)
    }
    
    func packageViewController(
        _ viewController: PackageViewController,
        didDelete package: WordPackage
    ) {
        self.showAlert(
            title: "Delete \(package.name)?",
            title2: nil,
            action: {
                [weak self] in
                guard let self = self else { return }
                navigationPresenter.popViewController(animated: true)
                packagesViewController.deletePackage(at: .init(row: currentPackageIndex, section: 0))
                self.packageService.savePackages(
                    self.packagesViewController.packages,
                    errorHandler: { error in
                        AlertKitAPI.present(
                            title: "\(error)",
                            subtitle: nil,
                            icon: .error,
                            style: .iOS17AppleMusic, 
                            haptic: .error
                        )
                    })
            })
    }
    
    private func showActivityController(_ url: URL, completion: @escaping () -> Void) {
        let files: [URL] = [url]
        let activityViewController = UIActivityViewController(
            activityItems: files,
            applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, error in
            completion()
        }
        if activityViewController.popoverPresentationController?.sourceView == nil {
            activityViewController.popoverPresentationController?.sourceView = self.navigationPresenter.viewControllers.first?.view
            activityViewController.popoverPresentationController?.sourceRect = self.navigationPresenter.viewControllers.first?.view?.frame ?? .zero
        }
        navigationPresenter.present(activityViewController, animated: true)
    }
    
    func packageViewController(_ viewController: PackageViewController, didTapShareWith package: WordPackage) {
        let backupService = BackupService(for: package)
        let result = backupService.backup()
        switch result {
        case .success(let url):
            self.showActivityController(url) {
                if let error = backupService.removeFile() {
                    AlertKitAPI.present(title: "\(error)", icon: .error, style: .iOS17AppleMusic, haptic: .error)
                }
            }
            break
        case .failure(let error):
            AlertKitAPI.present(title: "\(error)", icon: .error, style: .iOS17AppleMusic, haptic: .error)
            break
        }
    }
    
    func packageViewController(_ viewController: PackageViewController, didAdd word: Word) {
        packagesViewController.updatePackage(viewController.package, at: currentPackageIndex)
        packageService.savePackages(packagesViewController.packages, errorHandler: {
            error in
            AlertKitAPI.present(title: "\(error)", icon: .error, style: .iOS17AppleMusic, haptic: .error)
        })
    }
    
    func packageViewController(_ viewController: PackageViewController, didChangedPackageName name: String) {
        packagesViewController.updatePackage(viewController.package, at: currentPackageIndex)
        packageService.savePackages(packagesViewController.packages, errorHandler: {
            error in
            AlertKitAPI.present(title: "\(error)", icon: .error, style: .iOS17AppleMusic, haptic: .error)
        })
    }
    
    func packageViewController(_ viewController: PackageViewController, didTapShuffleWith package: WordPackage) {
        if package.words.isEmpty {
            let alert = UIAlertController(title: "No words in package", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Okay", style: .default) { _ in })
            navigationPresenter.present(alert, animated: true, completion: nil)
            return
        }
        let vc = CardStackViewController(cardContents: package.cardContentShufled)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        navigationPresenter.present(nvc, animated: true, completion: nil)
    }
    
    func packageViewController(_ viewController: PackageViewController, didTapReverseShuffleWith package: WordPackage) {
        if package.words.isEmpty {
            let alert = UIAlertController(title: "No words in package", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Okay", style: .default) { _ in })
            navigationPresenter.present(alert, animated: true, completion: nil)
            return
        }
        let vc = CardStackViewController(
            cardContents: package.words
                .map({
                    return CardContent(firstTitle: $0.secondTitle, secondTitle: $0.firstTitle)
                })
                .shuffled()
        )
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .overFullScreen
        navigationPresenter.present(nvc, animated: true, completion: nil)
    }
}
