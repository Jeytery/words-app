//
//  WordCardView.swift
//  WordsApp
//
//  Created by Jeytery on 25.10.2022.
//

import Foundation
import UIKit
import SnapKit

class WordCardView: UIView {
    
    private let titleLabel = UILabel()
    private let word: Word
    
    var isFliped: Bool = false
    
    @objc func tapGesture() {
        isFliped = !isFliped
        UIView.transition(
            with: self,
            duration: 0.5,
            options: .transitionFlipFromLeft,
            animations: nil,
            completion: nil
        )
        
        if isFliped {
            titleLabel.text = word.secondTitle
        }
        else {
            titleLabel.text = word.firstTitle
        }
    }
    
    init(word: Word, color: UIColor) {
        self.word = word
        super.init(frame: .zero)
        
        backgroundColor = color
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.8)
        }
        
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        self.layer.cornerRadius = 20
        
        titleLabel.text = word.firstTitle
        addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(tapGesture)
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
