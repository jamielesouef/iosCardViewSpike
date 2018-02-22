import UIKit

class ViewController: CardViewController {

  private lazy var pin: UIButton = CardViewFactory.pin
  override func viewDidLoad() {
    view.addSubview(pin)
    pin.addTarget(self, action: #selector(didSelectPin(sender:)), for: .touchUpInside)
    super.viewDidLoad()
  }

  override func layoutViews() {
    super.layoutViews()
    pin.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    pin.widthAnchor.constraint(equalToConstant: 30).isActive = true
    pin.heightAnchor.constraint(equalToConstant: 30).isActive = true
    pin.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
  }

  override func setupCardContent() {
    let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentNavigation")
    addCardViewController(controller: contentViewController)
  }
}
