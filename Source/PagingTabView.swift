import UIKit
import PureLayout

@objc public protocol PagingTabViewDelegate: NSObjectProtocol {
    @objc optional func pagingTabView(pagingTabView: PagingTabView, toIndex: Int)
    @objc optional func reconfigure(pagingTabView: PagingTabView)
}

public protocol PagingTabViewDataSource: NSObjectProtocol {
    func segments(pagingTabView: PagingTabView) -> Int
    func tabTitle(pagingTabView: PagingTabView, index: Int) -> (image: UIImage?, title: String?)
    func tabView(pagingTabView: PagingTabView, index: Int) -> UIView
}

open class PagingTabView: UIView {
    public var config: PagingTabViewConfig = PagingTabViewConfig()
    public weak var delegate: PagingTabViewDelegate?
    public weak var datasource: PagingTabViewDataSource!

    var curSelectedIndex = -1
    var animationInProgress = false

    public var tabButtons = [TabButton]()
    public var tabViews = [UIView]()

    public lazy var tabButtonContainer: UIView = {
        let view = UIView()

        view.layer.borderWidth = config.tabButtonContainerBorderWidth
        view.layer.borderColor = config.tabButtonContainerBorderColor.cgColor

        return view
    }()

    public lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }()

    // MARK: - UIView Methods -
    open func reloadAndSetup() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        tabViews.removeAll()
        for button in tabButtons {
            button.removeFromSuperview()
        }
        tabButtons.removeAll()
        [tabButtonContainer, scrollView].forEach { (view) in
            view.removeFromSuperview()
        }

        [tabButtonContainer, scrollView].forEach { (view) in
            self.addSubview(view)
        }


        let segments = datasource.segments(pagingTabView: self)
        for index in 0..<segments {
            let titleInfo: (image: UIImage?, title: String?) = datasource.tabTitle(pagingTabView: self, index: index)
            let tabView = datasource.tabView(pagingTabView: self, index: index)

            scrollView.addSubview(tabView)
            tabViews.append(tabView)

            let tabButton = TabButton()
            tabButton.tag = index
            tabButton.setup(titleInfo)

            let tapGest = UITapGestureRecognizer(target: self, action: #selector(PagingTabView.buttonTapped(recognizer:)))
            tapGest.numberOfTapsRequired = 1
            tabButton.addGestureRecognizer(tapGest)

            tabButtonContainer.addSubview(tabButton)
            tabButtons.append(tabButton)
        }

        self.select(0)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        tabButtonContainer.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        tabButtonContainer.autoSetDimension(.height, toSize: config.tabButtonContainerHeight)

        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        scrollView.autoPinEdge(.top, to: .bottom, of: tabButtonContainer)

        let buttons: NSArray = tabButtons as NSArray
        buttons.autoSetViewsDimension(.height, toSize: config.tabButtonHeight)
        buttons.autoDistributeViews(along: .horizontal, alignedTo: .horizontal, withFixedSpacing: 10.0, insetSpacing: true, matchedSizes: true)
        tabButtons.first?.autoAlignAxis(toSuperviewAxis: .horizontal)

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(tabViews.count), height: scrollView.frame.size.height)
        for i in 0..<tabViews.count {
            tabViews[i].frame = CGRect(x: scrollView.frame.size.width * CGFloat(i), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }
    }

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
            self.scrollView.contentOffset = CGPoint(x: CGFloat(index) * self.scrollView.frame.size.width, y: 0)
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
