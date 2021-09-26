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
