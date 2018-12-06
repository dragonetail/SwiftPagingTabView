import UIKit
import PureLayout

open class TabButton: UIView {
    open var config: TabButtonConfig = TabButtonConfig()

    open lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    open lazy var indicatorView: UIView = {
        let view = UIView()
        return view
    }()

    open var isSelected: Bool = false {
        didSet {
            if isSelected {
                button.titleLabel?.font = config.fontForSelected
                button.imageView?.tintColor = config.imageTintColorForSelected
                indicatorView.isHidden = false
            } else {
                button.titleLabel?.font = config.font
                button.imageView?.tintColor = config.imageTintColor
                indicatorView.isHidden = true
            }

            button.isSelected = isSelected
        }
    }


    open func setup(_ titleInfo: (image: UIImage?, title: String?)) {
        if let title = titleInfo.title {
            self.button.setTitle(title, for: .normal)
        }
        if let image = titleInfo.image {
            self.button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }

        [button, indicatorView].forEach({
            addSubview($0)
        })

        configure()
    }

    open func configure(config: TabButtonConfig? = nil) {
        if let config = config {
            self.config = config
        }

        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.setTitleColor(self.config.textColor, for: .normal)
        button.setTitleColor(self.config.textColorForSelected, for: .selected)
        button.setTitleShadowColor(UIColor.darkGray, for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: button.intrinsicContentSize.width - (button.titleLabel?.intrinsicContentSize.width ?? 0) + 14)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        button.imageView?.clipsToBounds = true
        button.imageView?.contentMode = .scaleToFill

        indicatorView.backgroundColor = self.config.indicatorColor
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        button.autoCenterInSuperview()

        //indicatorView.autoPinEdge(toSuperviewEdge: .left)
        //indicatorView.autoPinEdge(toSuperviewEdge: .right)
        indicatorView.autoPinEdge(.left, to: .left, of: button, withOffset: -3)
        indicatorView.autoPinEdge(.right, to: .right, of: button, withOffset: 3)
        indicatorView.autoPinEdge(.top, to: .bottom, of: button, withOffset: 0)
        indicatorView.autoSetDimension(.height, toSize: config.indicatorHeight)
    }
}
