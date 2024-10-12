//
//  AnimatedView.swift
//  CardPackageBoard
//
//  Created by Dmytro Ostapchenko on 28.04.2024.
//

import Foundation
import UIKit

class AnimatedView: UIView {
    var didTap: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.layer.removeAllAnimations()
        self.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.didTap?()
        UIView.animate(withDuration: 0.45, delay: 0, options: .allowUserInteraction, animations: {
            self.backgroundColor = .clear
        })
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.didTap?()
        UIView.animate(withDuration: 0.45, delay: 0, options: .allowUserInteraction, animations: {
            self.backgroundColor = .clear
        })
    }
}
