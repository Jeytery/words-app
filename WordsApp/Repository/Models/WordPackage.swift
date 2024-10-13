//
//  WordPackage.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import Foundation
import Upiter

struct WordPackage: Codable, Jsonable, Archivable {
    var name: String
    var words: Words
    
    static let empty = WordPackage(name: "", words: [])
    
    var firstRandomTen: Words {
        if words.count < 10 {
            return words
        }
        else {
            let _words = words.shuffled()
            return Array(_words[0...10])
        }
    }
    
    var cardContentShufled: [CardContent] {
        return self.words.map({ return CardContent(firstTitle: $0.firstTitle, secondTitle: $0.secondTitle) }).shuffled()
    }
}
typealias WordPackages = [WordPackage] 
