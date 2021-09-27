import PlaygroundSupport
import UIKit

// 泛型及协议的使用
protocol ItemPresenter {
    associatedtype Item
    var item: Item? { get set }
    static func cell(withIdentifier reuseIdentifier: String) -> UITableViewCell
}

typealias CommonTableViewCell = UITableViewCell & ItemPresenter

class CommonTableViewController<Cell: CommonTableViewCell>: UITableViewController {
    var items: [Cell.Item]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    var selectionHandler: ((IndexPath, Cell.Item) -> Void)?

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") ?? Cell.cell(withIdentifier: "CELL")
        if var commomCell = cell as? Cell {
            commomCell.item = self.items?[indexPath.row]
        } else {
            fatalError()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionHandler?(indexPath, (self.items?[indexPath.row])!)
    }
}

struct Contact {
    var name: String
    var phone: String
}

class ContactCell: UITableViewCell, ItemPresenter {
    static func cell(withIdentifier reuseIdentifier: String) -> UITableViewCell {
        return ContactCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    typealias Item = Contact
    var item: Contact? {
        didSet {
            self.textLabel?.text = self.item?.name
            self.detailTextLabel?.text = self.item?.phone
        }
    }
}

let contactListView = CommonTableViewController<ContactCell>()
contactListView.items = [
    Contact(name: "张三", phone: "186000001"),
    Contact(name: "李四", phone: "186000002")
]
contactListView.selectionHandler = {
    print("\($0),\($1.name)")
}

PlaygroundPage.current.liveView = contactListView

enum Event {
    case pageShow(param: [String: Any]?)
    case pageLeave(param: [String: Any]?)
    case click(param: [String: Any]?)
    case expro(param: [String: Any]?)
    var data: [String: Any] {
        var data = [String: Any]()
        switch self {
        case .pageShow(let param):
            data["event"] = "pageShow"
            data["param"] = param
        case .pageLeave(let param):
            data["event"] = "pageLeave"
            data["param"] = param
        case .expro(let param):
            data["event"] = "expro"
            data["param"] = param
        case .click(let param):
            data["event"] = "click"
            data["param"] = param
        }
        return data
    }
}

protocol Trackable {
    var pageName: String? { get set }
}

extension Trackable {
    func track(event: Event) {
        print(self.pageName ?? "")
        print(event.data)
    }
}

public class Tracker<Base: AnyObject>: Trackable {
    public weak var base: Base?
    public var pageName: String?
    fileprivate init(_ base: Base) {
        self.base = base
        if let vc = base as? UIViewController {
            self.pageName = vc.title
        }

        if let view = base as? UIView {
            var responder = view.next
            repeat {
                responder = responder?.next
            } while !(responder?.next is UIViewController)
            if let vc = responder as? UIViewController {
                self.pageName = vc.tracker.pageName
            }
        }
    }
}

private var trackerKey = ".trackerKey"
public protocol TrackerProvider: AnyObject {}
public extension TrackerProvider {
    var tracker: Tracker<Self> {
        var tracker = objc_getAssociatedObject(self, &trackerKey) as? Tracker<Self>
        if tracker == nil {
            tracker = Tracker(self)
            objc_setAssociatedObject(self, &trackerKey, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return tracker!
    }
}

extension UIViewController: TrackerProvider {}
public extension Tracker where Base: UIViewController {}

extension UIView: TrackerProvider {}
public extension Tracker where Base: UIView {}

contactListView.title = "联系人列表"
contactListView.tracker.track(event: .pageShow(param: nil))
// contactListView.tableView.tracker.track(event: .pageShow(param: nil))
