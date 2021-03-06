//
//  ExampleViewControllerType.swift
//  AutolayoutAndPurelayout
//
//  Created by dragonetail on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit

open class BaseViewControllerWithAutolayout: UIViewController {
    #if DEBUG
    open override func loadView() {
            print("\(self.title ?? "") loadView~~~")
            super.loadView()
            _ = self.view.autoresizingMask(accessibilityIdentifier)

            print("\(self.title ?? "") setupAndComposeView.")
            setupAndComposeView()

            // bootstrap Auto Layout
            view.setNeedsUpdateConstraints()
            print("\(self.title ?? "") loadView...")
        }

        open override func viewDidLoad() {
            print("\(self.title ?? "") viewDidLoad~~~")
            super.viewDidLoad()
            print("\(self.title ?? "") viewDidLoad...")
        }

        open override func viewWillAppear(_ animated: Bool) {
            print("\(self.title ?? "") viewWillAppear(\(animated))~~~")
            super.viewWillAppear(animated)

            print("\(self.title ?? "") viewWillAppear(\(animated))...")
        }

        open override func viewDidAppear(_ animated: Bool) {
            print("\(self.title ?? "") viewDidAppear(\(animated))~~~")
            super.viewDidAppear(animated)

            print("\(self.title ?? "") viewDidAppear(\(animated))...")
        }

        open override func viewWillDisappear(_ animated: Bool) {
            print("\(self.title ?? "") viewWillDisappear(\(animated))~~~")
            super.viewWillDisappear(animated)

            print("\(self.title ?? "") viewWillDisappear(\(animated))...")
        }

        open override func viewDidDisappear(_ animated: Bool) {
            print("\(self.title ?? "") viewDidDisappear(\(animated))~~~")
            super.viewDidDisappear(animated)

            print("\(self.title ?? "") viewDidDisappear(\(animated))...")
        }

        open override func viewWillLayoutSubviews() {
            print("\(self.title ?? "") viewWillLayoutSubviews~~~")
            super.viewWillLayoutSubviews()

            print("\(self.title ?? "") viewWillLayoutSubviews...")
        }

        open override func viewDidLayoutSubviews() {
            print("\(self.title ?? "") viewDidLayoutSubviews~~~")
            super.viewDidLayoutSubviews()

            //print(self.view.value(forKey: "_autolayoutTrace"))
            //self.view.autoPrintConstraints()
            //print("...")
            //self.view.superview?.autoPrintConstraints()

            print("\(self.title ?? "") viewDidLayoutSubviews...")
        }

        open override func updateViewConstraints() {
            print("\(self.title ?? "") updateViewConstraints~~~")
            if (!didSetupConstraints) {
                didSetupConstraints = true
                print("\(self.title ?? "") setupConstraints.")
                setupConstraints()
            }
            print("\(self.title ?? "") modifyConstraints.")
            modifyConstraints()

            super.updateViewConstraints()
            print("\(self.title ?? "") updateViewConstraints...")
        }

    #else
        open override func loadView() {
            super.loadView()
            _ = self.view.autoresizingMask(accessibilityIdentifier)

            setupAndComposeView()

            // bootstrap Auto Layout
            view.setNeedsUpdateConstraints()
        }

        open override func updateViewConstraints() {
            if (!didSetupConstraints) {
                didSetupConstraints = true
                setupConstraints()
            }
            modifyConstraints()

            super.updateViewConstraints()
        }
    #endif
    open var accessibilityIdentifier: String {
        return "VC"
    }

    open func setupAndComposeView() {
    }

    fileprivate var didSetupConstraints = false
    open func setupConstraints() {
    }
    open func modifyConstraints() {
    }
}


