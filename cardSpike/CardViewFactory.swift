import UIKit

struct CardViewFactory {
  static var cardHandle: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.lightGray
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    return view
  }()

  static var card: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  static var cardContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  static var pin: UIButton = {
    let view = UIButton()
    view.backgroundColor = UIColor.orange
    view.layer.shadowOpacity = 0.1
    view.layer.shadowRadius = 2
    view.layer.cornerRadius = 15
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}
