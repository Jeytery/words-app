//
//  ShuffleViewController.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import Foundation
import UIKit
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
        
        view.backgroundColor = .systemBackground
        floatingGesture.delegate = self
        
        configureCard()
        configureIndexLabel()
        configureReloadButton()
        configureLeftNavigationButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingGesture.reset()
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
            options: .allowUserInteraction,
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
            [weak self] in
            guard let self = self else { return }
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
            [weak self] in
            guard let self = self else { return }
            nextCardView?.alpha = 0.5
            nextCardView?.transform = .init(scaleX: 0.4, y: 0.4)
        }
    }
    
    private func hideNextCard() {
        animate {
            [weak self] in
            guard let self = self else { return }
            nextCardView?.alpha = 0
            nextCardView?.transform = .init(scaleX: 0.1, y: 0.1)
        }
    }
    
    private func showFullSizeNextCard() {
        animate {
            [weak self] in
            guard let self = self else { return }
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
            [weak self] in
            guard let self = self else { return }
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

struct CardContent: Codable {
    var firstTitle: String
    var secondTitle: String
}

class CardStackCardView: UIView {
    
    private let titleLabel = UILabel()
    private let cardContent: CardContent
    
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
            titleLabel.text = cardContent.secondTitle
        }
        else {
            titleLabel.text = cardContent.firstTitle
        }
    }
    
    init(word: CardContent, color: UIColor) {
        self.cardContent = word
        super.init(frame: .zero)
        
        backgroundColor = color
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/1.8)
        ])
        
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

final class CardStackViewController: UIViewController {

    private var cardContents: [CardContent]
    
    private let floatingGesture = FloatingGesture()
    
    // all ui
    private var currentCardView: CardStackCardView!
    private var nextCardView: CardStackCardView?

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
    
    init(cardContents: [CardContent]) {
        self.cardContents = cardContents
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .systemBackground
        floatingGesture.delegate = self
        configureCard()
        configureIndexLabel()
        configureReloadButton()
        configureLeftNavigationButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingGesture.reset()
    }

    required init?(coder: NSCoder) { fatalError() }
}

//MARK: - ui configuration
private extension CardStackViewController {
    func configureReloadButton() {
        view.addSubview(reloadButton)
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.layer.cornerRadius = 10
        reloadButton.backgroundColor = .secondarySystemFill
        reloadButton.imageView?.contentMode = .scaleToFill
        reloadButton.alpha = 0
        
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            reloadButton.heightAnchor.constraint(equalToConstant: 100),
            reloadButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        reloadButton.contentVerticalAlignment = .fill
        reloadButton.contentHorizontalAlignment = .fill
        reloadButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        reloadButton.tintColor = .secondaryLabel
        reloadButton.addTarget(self, action: #selector(reloadButtonDidTap), for: .touchUpInside)
    }
    
    @objc func reloadButtonDidTap() {
        reload()
    }
    
    func configureIndexLabel() {
        indexLabel = UILabel()
        indexLabel.text = "\(roleIndex + 1) of \(cardContents.count)"
        indexLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        indexLabel.textColor = .secondaryLabel
        indexLabel.textAlignment = .center
        
        view.addSubview(indexLabel)
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indexLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            indexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureCard() {
        currentCardView = CardStackCardView(word: cardContents[roleIndex], color: cardColor)
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
private extension CardStackViewController {
    func popIndexLabelIndex() {
        roleIndex -= 1
        indexLabel.text = "\(roleIndex + 1) of \(cardContents.count)"
    }
    
    func setIndexLabelIndex() {
        roleIndex += 1
        if roleIndex > cardContents.count - 1 { return }
        indexLabel.text = "\(roleIndex + 1) of \(cardContents.count)"
    }
    
    func setEndState() {
        UIView.animate(withDuration: 0.5) {
            [weak self] in
            guard let self = self else { return }
            reloadButton.alpha = 1
            indexLabel.alpha = 0
        }
    }

    func animate(_ animation: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .allowUserInteraction,
            animations: animation
        )
    }
}

//MARK: - stack logic
private extension CardStackViewController {
    func reload() {
        roleIndex = 0
        configureCard()
        currentCardView.alpha = 0
        indexLabel.text = "1 of \(cardContents.count)"
        cardContents.shuffle()
        UIView.animate(withDuration: 0.5) {
            [weak self] in
            guard let self = self else { return }
            currentCardView.alpha = 1
            reloadButton.alpha = 0
            indexLabel.alpha = 1
        }
    }
    
    var cardColor: UIColor {
        return cardColors.randomElement() ?? .systemRed
    }
    
    func showNextCard() {
        nextCardView = CardStackCardView(word: cardContents[roleIndex], color: cardColor)
        
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
    
    func hideNextCard() {
        animate {
            [self] in
            nextCardView?.alpha = 0
            nextCardView?.transform = .init(scaleX: 0.1, y: 0.1)
        }
    }
    
    func showFullSizeNextCard() {
        animate {
            [self] in
            nextCardView?.alpha = 1
            nextCardView?.transform = .init(scaleX: 1, y: 1)
        }
    }
}

extension CardStackViewController: FloatingGestureDelegate {
    func floatingGesture(_ gesture: FloatingGesture, didEndWith card: UIView) {
        hideNextCard()
        popIndexLabelIndex()
        animate {
            [weak self] in
            guard let self = self else { return }
            indexLabel.alpha = 1
        }
    }
    
    func floatingGesture(_ gesture: FloatingGesture, didEndWithout card: UIView) {
        if roleIndex == cardContents.count { return setEndState() }
        
        showFullSizeNextCard()

        currentCardView.gestureRecognizers?.removeAll()
        currentCardView = nextCardView
        currentCardView?.addGesture(floatingGesture)
        nextCardView = nil
    }
     
    func floatingGestureDidStart(_ gesture: FloatingGesture) {
        setIndexLabelIndex()
        if roleIndex == cardContents.count { return }
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

extension CardStackViewController: LeftNavigationButtonable {
    func leftNavigationButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func leftNavigationButtonSystemItem() -> UIBarButtonItem.SystemItem? {
        return .close
    }
}
