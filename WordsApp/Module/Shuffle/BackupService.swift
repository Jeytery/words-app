//
//  BackupService.swift
//  WordsApp
//
//  Created by Jeytery on 26.10.2022.
//

import Foundation

class BackupService {
    
    private let package: WordPackage
    private let filePath: String
    
    private let documentsUrl: URL
    private let fileUrl: URL
    
    init(for package: WordPackage) {
        self.package = package
        self.filePath = NSHomeDirectory() + "/Documents/" + "\(package.name).txt"
        self.documentsUrl = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileUrl = documentsUrl.appendingPathComponent(package.name + ".txt")
    }

    enum BackupServiceError: Error {
        case cantCreateFile
    }
}

private extension BackupService {
    func createPackageFile(
        _ package: WordPackage,
        filePath: String
    ) -> BackupServiceError? {
        guard FileManager
            .default
            .createFile(
                atPath: filePath,
                contents: nil,
                attributes: nil
            )
        else {
            return .cantCreateFile
        }
        return nil
    }
    
    func savePackageToFile(
        _ package: WordPackage,
        filePath: String
    ) throws {
        do {
            try package
                .json
                .write(
                    to: fileUrl,
                    atomically: true,
                    encoding: .utf8
                )
        }
        catch(let error) {
            throw error
        }
    }
}

extension BackupService {
    func backup() -> Result<URL, Error> {
        if let error = self.createPackageFile(self.package, filePath: self.filePath) {
            return .failure(error)
        }
        
        do {
            try self.savePackageToFile(
                self.package,
                filePath: self.filePath
            )
        }
        catch(let error) {
            return .failure(error)
        }
        
        return .success(fileUrl)
    }
    
    func removeFile() -> Error? {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch(let error) {
            return error
        }
        return nil
    }
}
