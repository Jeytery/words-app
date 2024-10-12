//
//  ShuffleViewController.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import Foundation
import UIKit
import FloatingGesture
import SnapKit
import NavigationButtonable

class ShuffleViewController: UIViewController {

    private var words: Words
    
    private let floatingGesture = FloatingGesture()
    
    // all ui
    private var currentCardView: WordCardView!
    private var nextCardView: WordCardView?

    private var indexLabel: UILabel!
    private let reloadButton = UIButton()
    
    private var cardColors: [UIColor] = {
        if #available(iOS 15, *) {
            return [.systemOrange, .systemBlue, .systemPurple, .systemRed, .systemCyan, .systemMint, .systemPink]
        }
        else {
            return [.systemOrange, .systemBlue, .systemPurple, .systemRed, .systemPink]
        }
    }()
    
    // state vars
    private var roleIndex: Int = 0
    
    init(words: Words) {
        self.words = words
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .tertiarySystemGroupedBackground
        floatingGesture.delegate = self
        
        configureCard()
        configureIndexLabel()
        configureReloadButton()
        configureLeftNavigationButton()
    }

    required init?(coder: NSCoder) { fatalError() }
}

//MARK: - ui configuration
extension ShuffleViewController {
    private func configureReloadButton() {
        view.addSubview(reloadButton)
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.layer.cornerRadius = 10
        reloadButton.backgroundColor = .secondarySystemFill
        reloadButton.imageView?.contentMode = .scaleToFill
        reloadButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(100)
        }
        reloadButton.alpha = 0
        
        reloadButton.contentVerticalAlignment = .fill
        reloadButton.contentHorizontalAlignment = .fill
        reloadButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        reloadButton.tintColor = .secondaryLabel
        reloadButton.addTarget(self, action: #selector(reloadButtonDidTap), for: .touchUpInside)
    }
    
    @objc func reloadButtonDidTap() {
        reload()
    }
    
    private func configureIndexLabel() {
        indexLabel = UILabel()
        indexLabel.text = "\(roleIndex + 1) of \(words.count)"
        indexLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        indexLabel.textColor = .secondaryLabel
        indexLabel.textAlignment = .center
        
        view.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureCard() {
        currentCardView = WordCardView(word: words[roleIndex], color: cardColor)
        view.addSubview(currentCardView)
        currentCardView.translatesAutoresizingMaskIntoConstraints = false
        currentCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currentCardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        currentCardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 7/11).isActive = true
        currentCardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        currentCardView.addGesture(floatingGesture)
    }
}

//MARK: - ui logic
extension ShuffleViewController {
    private func popIndexLabelIndex() {
        roleIndex -= 1
        indexLabel.text = "\(roleIndex + 1) of \(words.count)"
    }
    
    private func setIndexLabelIndex() {
        roleIndex += 1
        if roleIndex > words.count - 1 { return }
        indexLabel.text = "\(roleIndex + 1) of \(words.count)"
    }
    
    private func setEndState() {
        UIView.animate(withDuration: 0.5) {
            [unowned self] in
            reloadButton.alpha = 1
            indexLabel.alpha = 0
        }
    }

    private func animate(_ animation: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseIn,
            animations: animation
        )
    }
}

//MARK: - stack logic
extension ShuffleViewController {
    private func reload() {
        roleIndex = 0
        configureCard()
        currentCardView.alpha = 0
        
        words.shuffle()
       
        UIView.animate(withDuration: 0.5) {
            [unowned self] in
            currentCardView.alpha = 1
            reloadButton.alpha = 0
            indexLabel.alpha = 1
        }
    }
    
    private var cardColor: UIColor {
        return cardColors.randomElement() ?? .systemRed
    }
    
    private func showNextCard() {
        nextCardView = WordCardView(word: words[roleIndex], color: cardColor)
        
        view.addSubview(nextCardView!)
        
        nextCardView!.translatesAutoresizingMaskIntoConstraints = false
        nextCardView!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextCardView!.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nextCardView!.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 7/11).isActive = true
        nextCardView!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        
        nextCardView!.alpha = 0
        nextCardView!.transform = .init(scaleX: 0.1, y: 0.1)
        
        view.sendSubviewToBack(nextCardView!)
        
        animate {
            [self] in
            nextCardView?.alpha = 0.5
            nextCardView?.transform = .init(scaleX: 0.4, y: 0.4)
        }
    }
    
    private func hideNextCard() {
        animate {
            [self] in
            nextCardView?.alpha = 0
            nextCardView?.transform = .init(scaleX: 0.1, y: 0.1)
        }
    }
    
    private func showFullSizeNextCard() {
        animate {
            [self] in
            nextCardView?.alpha = 1
            nextCardView?.transform = .init(scaleX: 1, y: 1)
        }
    }
}

extension ShuffleViewController: FloatingGestureDelegate {
    func floatingGesture(_ gesture: FloatingGesture, didEndWith card: UIView) {
        hideNextCard()
        popIndexLabelIndex()
        animate {
            [self] in
            indexLabel.alpha = 1
        }
    }
    
    func floatingGesture(_ gesture: FloatingGesture, didEndWithout card: UIView) {
        if roleIndex == words.count { return setEndState() }
        
        showFullSizeNextCard()

        currentCardView.gestureRecognizers?.removeAll()
        currentCardView = nextCardView
        currentCardView?.addGesture(floatingGesture)
        nextCardView = nil
    }
     
    func floatingGestureDidStart(_ gesture: FloatingGesture) {
        setIndexLabelIndex()
        if roleIndex == words.count { return }
        showNextCard()
    }
    
    func floatingGesutre(
        _ gesture: FloatingGesture,
        didChangedWith yOffset: CGFloat,
        with range: ClosedRange<CGFloat>
    ) {
        let toDiaposon: ClosedRange<CGFloat> = 0.4 ... 0.9
        var offset = yOffset
        
        if offset < 0 { offset = -offset }
        if offset > range.upperBound { offset = range.upperBound }
        
        let cardScale = Math.mapDiaposons(value: offset, from: range, to: toDiaposon)

        nextCardView?.transform = .init(scaleX: cardScale, y: cardScale)
    }
    
    func floatingGesture(
        _ gesture: FloatingGesture,
        didEndAnimation isWithCard: Bool
    ) {
        currentCardView?.addGesture(floatingGesture)
    }
}

extension ShuffleViewController: LeftNavigationButtonable {
    func leftNavigationButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func leftNavigationButtonSystemItem() -> UIBarButtonItem.SystemItem? {
        return .close
    }
}
