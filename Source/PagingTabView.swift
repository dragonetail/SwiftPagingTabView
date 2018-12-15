import UIKit
import PureLayout
import SwiftBaseBootstrap

@objc public protocol PagingTabViewDelegate: NSObjectProtocol {
    @objc optional func pagingTabView(pagingTabView: PagingTabView, toIndex: Int)
    @objc optional func reconfigure(pagingTabView: PagingTabView)
}

public protocol PagingTabViewDataSource: NSObjectProtocol {
    func segments(pagingTabView: PagingTabView) -> Int
    func tabTitle(pagingTabView: PagingTabView, index: Int) -> (image: UIImage?, title: String?)
    func tabView(pagingTabView: PagingTabView, index: Int) -> UIView
}

@available(iOS 9.0, *)
open class PagingTabView: BaseViewWithAutolayout {
    public var config: PagingTabViewConfig = PagingTabViewConfig() {
        didSet {
            borderStackViewContainer(stackViewContainer)
        }
    }
    public weak var delegate: PagingTabViewDelegate?
    public weak var datasource: PagingTabViewDataSource?

    var curSelectedIndex = -1
    var animationInProgress = false

    public var tabButtons = [TabButton]()
    public var tabViews = [UIView]()

    public lazy var stackViewContainer: UIView = {
        let stackViewContainer = UIView().autoLayout("stackViewContainer")

        borderStackViewContainer(stackViewContainer)
        
        self.addSubview(stackViewContainer)
        stackViewContainer.addSubview(tabButtonStackView)

        return stackViewContainer
    }()
    func borderStackViewContainer(_ stackViewContainer: UIView){
        stackViewContainer.layer.borderWidth = config.tabButtonContainerBorderWidth
        stackViewContainer.layer.borderColor = config.tabButtonContainerBorderColor.cgColor
        stackViewContainer.layer.cornerRadius = config.tabButtonContainerCornerRadius
        //stackViewContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        stackViewContainer.clipsToBounds = true
    }
    
    public lazy var tabButtonStackView: UIStackView = {
        let tabButtonStackView = UIStackView().autoLayout("tabButtonStackView")

        tabButtonStackView.axis = .horizontal
        tabButtonStackView.alignment = .center
        tabButtonStackView.distribution = .equalSpacing
        tabButtonStackView.spacing = 6

        return tabButtonStackView
    }()

    public lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView().autoLayout("PagingTabView")
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        self.addSubview(scrollView)
        return scrollView
    }()

    open override func setupAndComposeView() {
        _ = self.autoLayout("PagingTabView")

        guard let datasource = datasource else {
            return
        }

        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        tabViews.removeAll()
        for view in tabButtonStackView.arrangedSubviews {
            tabButtonStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        tabButtons.removeAll()

        //Dummy for layout the leading
        tabButtonStackView.addArrangedSubview(UIView())
        let segments = datasource.segments(pagingTabView: self)
        for index in 0..<segments {
            let titleInfo: (image: UIImage?, title: String?) = datasource.tabTitle(pagingTabView: self, index: index)
            let tabView = datasource.tabView(pagingTabView: self, index: index)

            scrollView.addSubview(tabView)
            tabViews.append(tabView)

            let tabButton = TabButton().autoLayout("tabButton_\(index)")
            tabButton.tag = index
            tabButton.title = titleInfo.title
            tabButton.image = titleInfo.image

            let tapGest = UITapGestureRecognizer(target: self, action: #selector(PagingTabView.buttonTapped(recognizer:)))
            tapGest.numberOfTapsRequired = 1
            tabButton.addGestureRecognizer(tapGest)

            tabButtonStackView.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
        }
        //Dummy for layout the tailing
        tabButtonStackView.addArrangedSubview(UIView())

        self.delegate?.reconfigure?(pagingTabView: self)

        self.select(0)

        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }

    open override func setupConstraints() {
        stackViewContainer.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        stackViewContainer.autoSetDimension(.height, toSize: config.tabButtonContainerHeight)
        tabButtonStackView.autoPinEdgesToSuperviewEdges()

        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        scrollView.autoPinEdge(.top, to: .bottom, of: tabButtonStackView)
    }
    open override func modifyConstraints() {
        for i in 0..<tabViews.count {
            tabViews[i].autoMatch(.width, to: .width, of: scrollView)
            tabViews[i].autoMatch(.height, to: .height, of: scrollView)

            if i == 0 {
                tabViews[i].autoPinEdge(.left, to: .left, of: scrollView, withOffset: 0)
            } else {
                tabViews[i].autoPinEdge(.left, to: .right, of: tabViews[i - 1], withOffset: 0)
            }
            if(i == tabViews.count - 1) {
                tabViews[i].autoPinEdge(.right, to: .right, of: scrollView, withOffset: 0)
            }
        }
    }

    //open override func layoutSubviews() {
    //    super.layoutSubviews()
    //}

    // MARK: - Public Methods -
    open func select(_ index: Int, animated: Bool = true) {
        moveToIndex(index: index, animated: animated, moveScrollView: true)
    }

    // MARK: - Events -
    @objc internal func buttonTapped(recognizer: UITapGestureRecognizer) {
        let sender = recognizer.view as! TabButton

        let selectedIndex = sender.tag
        guard selectedIndex != curSelectedIndex else {
            return
        }

        delegate?.pagingTabView?(pagingTabView: self, toIndex: selectedIndex)

        moveToIndex(index: selectedIndex, animated: config.animated, moveScrollView: true)
    }

    // MARK: - Helper -
    func moveToIndex(index: Int, animated: Bool, moveScrollView: Bool) {
        curSelectedIndex = index

        if !animated {
            moveToIndex(index: index, moveScrollView: moveScrollView)
            return
        }

        animationInProgress = true

        UIView.animate(withDuration: TimeInterval(config.animationDuration), delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            self?.moveToIndex(index: index, moveScrollView: moveScrollView)
        }, completion: { [weak self] finished in
            self?.animationInProgress = false
        })
    }

    func moveToIndex(index: Int, moveScrollView: Bool) {
        self.tabButtons.forEach { (button) in
            button.isSelected = false
        }

        let button = self.tabButtons[index]
        button.isSelected = true

        if moveScrollView {
            self.scrollView.contentOffset = CGPoint(x: CGFloat(index) * (self.scrollView.frame.size.width), y: 0)
        }
    }
}

// MARK: - UIScrollView Delegate -
extension PagingTabView: UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !animationInProgress {
            var page = scrollView.contentOffset.x / scrollView.frame.size.width

            if page.truncatingRemainder(dividingBy: 1) > 0.5 {
                page = page + CGFloat(1)
            }

            if Int(page) != curSelectedIndex {
                moveToIndex(index: Int(page), animated: config.animated, moveScrollView: false)
                delegate?.pagingTabView?(pagingTabView: self, toIndex: Int(page))
            }
        }
    }

}
