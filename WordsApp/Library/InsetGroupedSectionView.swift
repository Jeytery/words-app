//
//  InsetGroupedSectionView.swift
//  CardPackageBoard
//
//  Created by Dmytro Ostapchenko on 25.04.2024.
//

import Foundation
import UIKit

struct InsetGropedSectionData {
    init(
        cells: [InsetGropedSectionData.Cell],
        header: InsetGropedSectionData.HeaderData = .init(
            view: UIView(),
            height: 0,
            insets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        ),
        footer: InsetGropedSectionData.FooterData = .init(
            view: UIView(),
            height: 0,
            insets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        )
    ) {
        self.cells = cells
        self.header = header
        self.footer = footer
        self.didTap = {}
    }
    
    struct Cell {
        init(view: UIView, height: CGFloat, insets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), didTap: (() -> Void)? = nil) {
            self.view = view
            self.height = height
            self.insets = insets
            self.didTap = didTap
        }
        
        let view: UIView
        let height: CGFloat
        let insets: UIEdgeInsets
        let didTap: (() -> Void)? 
    }
    struct HeaderData {
        let view: UIView
        let height: CGFloat
        let insets: UIEdgeInsets
        
        init(view: UIView, height: CGFloat, insets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)) {
            self.view = view
            self.height = height
            self.insets = insets
        }
    }
    struct FooterData {
        let view: UIView
        let height: CGFloat
        let insets: UIEdgeInsets
        
        init(view: UIView, height: CGFloat, insets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)) {
            self.view = view
            self.height = height
            self.insets = insets
        }
    }
    let cells: [Cell]
    let header: HeaderData
    let footer: FooterData
    let didTap: (() -> Void)?
}

fileprivate final class ViewWithHandler: UIView {
    var handler: (() -> Void)?
    private let _view = AnimatedView()
    
    enum CornerRadiusMode {
        case bottomCorners
        case topCorners
        case no
        case all
    }
    
    init(view: UIView, handler: (() -> Void)? = nil, cornerRadiusMode: CornerRadiusMode = .no) {
        super.init(frame: .zero)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        _view.backgroundColor = .clear
        addSubview(_view)
        _view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _view.topAnchor.constraint(equalTo: topAnchor),
            _view.leftAnchor.constraint(equalTo: leftAnchor, constant: -20),
            _view.rightAnchor.constraint(equalTo: rightAnchor, constant: 20),
            _view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        _view.didTap = {
            handler?()
        }
        
        switch cornerRadiusMode {
        case .bottomCorners:
            _view.clipsToBounds = true
            _view.layer.cornerRadius = 12
            _view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .topCorners:
            _view.clipsToBounds = true
            _view.layer.cornerRadius = 12
            _view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .all:
            _view.layer.cornerRadius = 12
            _view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        case .no:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InsetGroupedSectionView: UIView {
    
    private var cells: [UIView] = []
    private var lineViews: [UIView] = []
    private let viewsCount: Int
    
    private let mainView = UIView()
    
    private let data: InsetGropedSectionData
    
    init(frame: CGRect = .zero, data: InsetGropedSectionData) {
        self.data = data
        self.viewsCount = data.cells.count
        super.init(frame: frame)
        // header
        let headerView = data.header.view
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: data.header.insets.top),
            headerView.leftAnchor.constraint(equalTo: leftAnchor, constant: data.header.insets.left),
            headerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -data.header.insets.right),
            headerView.heightAnchor.constraint(equalToConstant: data.header.height)
        ])
        // mainView
        mainView.backgroundColor = .secondarySystemGroupedBackground
        mainView.layer.cornerRadius = 12
        mainView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: data.header.insets.bottom),
            mainView.leftAnchor.constraint(equalTo: leftAnchor),
            mainView.rightAnchor.constraint(equalTo: rightAnchor),
            mainView.heightAnchor.constraint(
                equalToConstant: data.cells.reduce(0, {
                    if $0 == 0 {
                        $0 + $1.height + $1.insets.bottom + $1.insets.top
                    }
                    else {
                        $0 + $1.height + $1.insets.bottom + $1.insets.top + self.lineViewHeight
                    }
                })
            )
        ])
        // footer
        let footerView = data.footer.view
        footerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(footerView)
        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: data.footer.insets.top),
            footerView.leftAnchor.constraint(equalTo: leftAnchor, constant: data.footer.insets.left),
            footerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -data.footer.insets.right),
            footerView.heightAnchor.constraint(equalToConstant: data.footer.height),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -data.footer.insets.bottom)
        ])
        var index = 0
        data.cells.forEach {
            setupView($0.view, height: $0.height, insets: $0.insets, index: index, didTap: $0.didTap)
            index += 1
        }
    }
    
    private func setupView(_ _view: UIView, height: CGFloat, insets: UIEdgeInsets, index: Int, didTap: (() -> Void)?) {
        let view: ViewWithHandler = {
            if data.cells.count == 1 {
                return ViewWithHandler(view: _view, handler: didTap, cornerRadiusMode: .all)
            }
            else if index == 0 {
                return ViewWithHandler(view: _view, handler: didTap, cornerRadiusMode: .topCorners)
            }
            
            else if index == (data.cells.count - 1) {
                return ViewWithHandler(view: _view, handler: didTap, cornerRadiusMode: .bottomCorners)
            }
           
            else {
                return ViewWithHandler(view: _view, handler: didTap, cornerRadiusMode: .no)
            }
        }()
        view.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(view)
        if lineViews.isEmpty {
            view.topAnchor.constraint(equalTo: mainView.topAnchor, constant: insets.top).isActive = true
        }
        else {
            view.topAnchor.constraint(equalTo: lineViews.last!.bottomAnchor, constant: insets.top).isActive = true
        }
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.cells.append(view)
        if lineViews.count < viewsCount - 1 {
            let lineView = UIView()
            lineView.backgroundColor = .secondarySystemFill
            lineView.translatesAutoresizingMaskIntoConstraints = false
            mainView.addSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
                lineView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 20),
                lineView.rightAnchor.constraint(equalTo: mainView.rightAnchor),
                lineView.heightAnchor.constraint(equalToConstant: lineViewHeight),
            ])
            lineViews.append(lineView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lineViewHeight: CGFloat = 0.85
    
    var dynamicHeight: CGFloat {
        return data.cells.reduce(0, {
            if $0 == 0 {
                $0 + $1.height + $1.insets.bottom + $1.insets.top
            }
            else {
                $0 + $1.height + $1.insets.bottom + $1.insets.top + self.lineViewHeight
            }
        })
        + data.header.height
        + data.footer.height
        + data.header.insets.top
        + data.header.insets.bottom
        + data.footer.insets.top
        + data.footer.insets.bottom
    }
}


