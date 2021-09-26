//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

@resultBuilder
struct AttributedStringBuilder {
  static func buildBlock(_ segments: NSAttributedString...) -> NSAttributedString {
    let string = NSMutableAttributedString()
    segments.forEach { string.append($0) }
    return string
  }
}

extension NSAttributedString {
  convenience init(@AttributedStringBuilder _ content: () -> NSAttributedString) {
    self.init(attributedString: content())
  }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        
        label.attributedText = NSAttributedString {
            "Hello "
              .foregroundColor(.red)
              .font(UIFont.systemFont(ofSize: 10.0))
            "World"
              .foregroundColor(.green)
              .underline(.orange, style: .thick)
        }
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
