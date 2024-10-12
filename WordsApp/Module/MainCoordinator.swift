//
//  MainCoordinator.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import UIKit

class MainCoordinator {
    private(set) var navigationPresenter = UINavigationController()
    private var currentPackageIndex: Int = 0
    
    init() {
        navigationPresenter.setViewControllers([packageVC], animated: false)
        packageVC.delegate = self
    }
    
    private let packageVC = PackagesViewController.module()
}

extension MainCoordinator: PackagesViewControllerDelegate, PackageViewControllerDelegate {
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
        let vc = ShuffleViewController(
            words: package.firstRandomTen
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
    
    func packageViewController(
        _ viewController: PackageViewController,
        didReturn package: WordPackage
    ) {
        packageVC.updatePackage(package, at: currentPackageIndex)
    }
}
