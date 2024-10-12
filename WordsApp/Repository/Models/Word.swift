//
//  Word.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import Foundation

struct Word: Codable {
    var firstTitle: String
    var secondTitle: String
    var rating: Int
}
typealias Words = [Word]
