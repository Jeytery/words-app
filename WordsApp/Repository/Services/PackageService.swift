//
//  PackageService.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import Foundation
import Upiter

enum PackageServiceError: Error {
    case emptyPackages
    case nilPackages
    case archiveFailure
}

protocol PackageServiceTarget: AnyObject {
    func getPackages(
        _ completion: @escaping (Result<WordPackages, PackageServiceError>) -> Void
    )
    
    func savePackages(_ packages: WordPackages, errorHandler: (([PackageServiceError]) -> Void)?)
}

class PackageService {
    private let userDefaults = UserDefaults.standard
    private let key = "PackageService.UserDefaults.key"
}

extension PackageService: PackageServiceTarget {
    func getPackages(_ completion: @escaping (Result<WordPackages, PackageServiceError>) -> Void) {
        guard let data = userDefaults.data(forKey: key) else {
            return completion(.failure(.emptyPackages))
        }
        
        guard let packages = WordPackages.unarchive(data: data) else {
            return completion(.failure(.nilPackages))
        }
        
        completion(.success(packages))
    }
    
    func savePackages(
        _ packages: WordPackages,
        errorHandler: (([PackageServiceError]) -> Void)?
    ) {
        guard let data = packages.archive() else {
            errorHandler?(
                [.archiveFailure]
            )
            return
        }
        userDefaults.removePersistentDomain(forName: key)
        userDefaults.set(data, forKey: key)
    }
}







