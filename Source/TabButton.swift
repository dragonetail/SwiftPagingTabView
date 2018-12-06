import UIKit
import PureLayout

open class TabButton: UIView {
    open var config: TabButtonConfig = TabButtonConfig()

    open var imageView: UIImageView?
    open var titleLabel: UILabel?
    open lazy var indicatorView: UIView = {
        let view = UIView()
        return view
    }()

    open var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel?.font = config.fontForSelected
                titleLabel?.textColor = config.textColorForSelected
                imageView?.tintColor = config.imageTintColorForSelected
                indicatorView.isHidden = false
            } else {
                titleLabel?.font = config.font
                titleLabel?.textColor = config.textColor
                imageView?.tintColor = config.imageTintColor
                indicatorView.isHidden = true
            }
        }
    }

    open func setup(_ titleInfo: (image: UIImage?, title: String?)) {
        if let title = titleInfo.title {
            self.titleLabel = UILabel()
            self.titleLabel?.text = title
            addSubview(self.titleLabel!)
        }
        if let image = titleInfo.image {
            self.imageView = UIImageView()
            self.imageView?.image = image.withRenderingMode(.alwaysTemplate)
            imageView?.clipsToBounds = true
            imageView?.contentMode = .scaleToFill
            addSubview(self.imageView!)
        }

        [indicatorView].forEach({
            addSubview($0)
        })

        configure()
    }

    open func configure(config: TabButtonConfig? = nil) {
        if let config = config {
            self.config = config
        }

        indicatorView.backgroundColor = self.config.indicatorColor

        self.invalidateIntrinsicContentSize()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let imageSize = self.bounds.height - config.imageViewTopDownMargin * 2
        let leftRightMargin = (self.bounds.width - intrinsicContentSize.width) / 2
        let titleLabelHeight = titleLabel?.bounds.size.height ?? 0
        let titleLabelTopDownMargin = (self.bounds.height - titleLabelHeight) / 2

        defer {
            
        }

        if let titleLabel = self.titleLabel,
            let imageView = self.imageView {
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: config.imageViewTopDownMargin, left: leftRightMargin, bottom: config.imageViewTopDownMargin, right: 0), excludingEdge: .right)
            imageView.autoSetDimensions(to: CGSize(width: imageSize, height: imageSize))
            imageView.setNeedsDisplay()

            titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: titleLabelTopDownMargin, left: 0, bottom: titleLabelTopDownMargin, right: leftRightMargin), excludingEdge: .left)
            titleLabel.autoPinEdge(.left, to: .right, of: imageView, withOffset: 5)
            
            indicatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: leftRightMargin - 3, bottom: 0, right: leftRightMargin - 3), excludingEdge: .top)
            indicatorView.autoSetDimension(.height, toSize: config.indicatorHeight)
            return
        }
        if let titleLabel = self.titleLabel {
            titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: titleLabelTopDownMargin, left: leftRightMargin, bottom: titleLabelTopDownMargin, right: leftRightMargin))
            
            indicatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: leftRightMargin - 3, bottom: 3, right: leftRightMargin - 3), excludingEdge: .top)
            indicatorView.autoSetDimension(.height, toSize: config.indicatorHeight)
            return
        }

        if let imageView = self.imageView {
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: config.imageViewTopDownMargin, left: leftRightMargin, bottom: config.imageViewTopDownMargin, right: 0), excludingEdge: .right)
            imageView.autoSetDimensions(to: CGSize(width: imageSize, height: imageSize))
            imageView.setNeedsDisplay()
            
            //DO NOT Display
            //indicatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: leftRightMargin - 3, bottom: 0, right: leftRightMargin - 3), excludingEdge: .top)
            //indicatorView.autoSetDimension(.height, toSize: config.indicatorHeight)
            return
        }
    }

    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        titleLabel?.sizeToFit()

        let imageSize = self.bounds.height - config.imageViewTopDownMargin * 2

        var width: CGFloat = 0.0
        if let _ = imageView {
            width = width + imageSize + 5.0
        }
        if let titleLabelWidth = titleLabel?.frame.size.width {
            width = width + titleLabelWidth
        }
        return CGSize(width: width, height: size.height)
    }


}
