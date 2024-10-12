//
//  PackagesViewController+Module.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import Foundation

extension PackagesViewController {
    static func module() -> PackagesViewController {
        let service = PackageService()
        let viewController = PackagesViewController(packageService: service)
        return viewController
    }
}
