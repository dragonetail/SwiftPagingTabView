//
//  BaseViewWithAutolayout.swift
//  AutolayoutAndPurelayout
//
//  Created by dragonetail on 2018/12/13.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit

open class BaseViewWithAutolayout: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _ = self.autoLayout("BaseView")

        setupAndComposeView()

        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Should overritted by subclass, setup view and compose subviews
    open func setupAndComposeView() {
    }

    fileprivate var didSetupConstraints = false
    open override func updateConstraints() {
        if (!didSetupConstraints) {
            didSetupConstraints = true
            setupConstraints()
        }
        modifyConstraints()

        super.updateConstraints()
    }

    // invoked only once
    open func setupConstraints() {
    }

    open func modifyConstraints() {
    }
}

