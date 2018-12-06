import UIKit
import SwiftPagingTabView

class ViewController: UIViewController {

    public lazy var pagingTabView: PagingTabView = {
        let pagingTabView: PagingTabView = PagingTabView()
        pagingTabView.config = PagingTabViewConfig()
        pagingTabView.delegate = self
        pagingTabView.datasource = self

        return pagingTabView
    }()
    public lazy var commandView: CommandView = {
        let view = CommandView()
        view.setup(pagingTabView: pagingTabView)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(pagingTabView)

        pagingTabView.reloadAndSetup()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        pagingTabView.autoPinEdgesToSuperviewSafeArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ViewController: PagingTabViewDelegate {
    func pagingTabView(pagingTabView: PagingTabView, toIndex: Int) {
        print("Switch to paging tab view: \(toIndex)")
    }

    func reconfigure(pagingTabView: PagingTabView) {
        pagingTabView.tabButtons.forEach { (tabButton) in
            tabButton.configure(config: TabButtonConfig())
        }
    }
}
extension ViewController: PagingTabViewDataSource {
    func segments(pagingTabView: PagingTabView) -> Int {
        return 4
    }

    func tabTitle(pagingTabView: PagingTabView, index: Int) -> (image: UIImage?, title: String?) {
        if commandView.isEnableImageTitle {
            return (image: UIImage(named: "menu"),
                    title: "TAB标签_" + String(index))
        } else {
            return (image: nil,
                    title: "TAB标签_" + String(index))
        }
    }

    func tabView(pagingTabView: PagingTabView, index: Int) -> UIView {
        if index == 0 {
            return commandView
        } else {
            let view = UILabel()
            view.backgroundColor = UIColor.white
            view.text = "View " + String(index)
            view.textAlignment = .center
            return view
        }
    }
}

class CommandView: UIView {
    var isEnableImageTitle: Bool = false {
        didSet {
            if isEnableImageTitle {
                enableImageTitleButton.setTitle("Disable Image Tab Title", for: .normal)
            } else {
                enableImageTitleButton.setTitle("Enable Image Tab Title", for: .normal)
            }
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Hi, nice to meet you ~"
        return label
    }()
    private lazy var enableImageTitleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable Image Tab Title", for: .normal)
        button.addTarget(self, action: #selector(CommandView.buttonTapped(sender:)), for: .touchUpInside)

        return button
    }()

    @objc internal func buttonTapped(sender: UIButton) {
        isEnableImageTitle = !isEnableImageTitle

        pagingTabView.reloadAndSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var pagingTabView: PagingTabView!
    func setup(pagingTabView: PagingTabView) {
        self.pagingTabView = pagingTabView

        [label, enableImageTitleButton].forEach({
            addSubview($0)
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.autoCenterInSuperview()

        enableImageTitleButton.autoAlignAxis(toSuperviewAxis: .vertical)
        enableImageTitleButton.autoPinEdge(.top, to: .bottom, of: label, withOffset: 15)
    }
}
