import UIKit

class CardViewController: UIViewController {

  private lazy var cardHandle: UIView = CardViewFactory.cardHandle
  private lazy var card: UIView = CardViewFactory.card
  private lazy var cardContainerView: UIView = CardViewFactory.cardContainerView

  private var animationSpeed: TimeInterval = 0.5
  private var cardState: CardStates = .dismissed
  private var bottomConstraint = NSLayoutConstraint()
  private var runningAnimator: UIViewPropertyAnimator?
  private var cardSizes: CardSizes = CardSizes()

  var contentView: UIView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCardContent()
    addAllViews()
    layoutViews()
    setupTouchEvents()
  }

  @objc
  func cardTapGesture(tap: UITapGestureRecognizer) {
    switch cardState {
    case .context, .peek: animateCard(toState: .full)
    default: ()
    }
  }

  @objc
  func didDismissCard(tap: UITapGestureRecognizer) {
    animateCard(toState: .dismissed)
  }

  @objc
  func didSelectPin(sender: UIButton) {
    animateCard(toState: .peek)
  }

  @objc
  func didPanCard(pan: UIPanGestureRecognizer) {
    animateCard(pan: pan)
  }

  func setupCardContent() {
  }

  func addAllViews() {
    if let contentView = contentView { cardContainerView.addSubview(contentView) }
    card.addSubview(cardContainerView)

    view.addSubview(card)

    cardContainerView.layer.masksToBounds = true
    card.addSubview(cardHandle)
    card.bringSubview(toFront: cardHandle)
    view.bringSubview(toFront: card)
  }

  func layoutViews() {

    cardSizes = CardSizes(withFrame: view.frame)

    card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    card.heightAnchor.constraint(equalToConstant: cardSizes.full.height).isActive = true
    bottomConstraint = card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: cardSizes.full.height)
    bottomConstraint.isActive = true

    cardContainerView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 0).isActive = true
    cardContainerView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: 0).isActive = true
    cardContainerView.topAnchor.constraint(equalTo: card.topAnchor, constant: 0).isActive = true
    cardContainerView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: 0).isActive = true

    if let contentView = contentView {
      contentView.translatesAutoresizingMaskIntoConstraints = false
      contentView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 0).isActive = true
      contentView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: 0).isActive = true
      contentView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 0).isActive = true
      contentView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 0).isActive = true
    }

    cardHandle.topAnchor.constraint(equalTo: card.topAnchor, constant: 6).isActive = true
    cardHandle.widthAnchor.constraint(equalToConstant: 50).isActive = true
    cardHandle.heightAnchor.constraint(equalToConstant: 10).isActive = true
    cardHandle.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
  }

  func setupTouchEvents() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanCard(pan:)))
    let tapDrawingGesture = UITapGestureRecognizer(target: self, action: #selector(didDismissCard(tap:)))
    let tapCardHandler = UITapGestureRecognizer(target: self, action: #selector(cardTapGesture(tap:)))

    panGesture.delaysTouchesBegan = false
    panGesture.delaysTouchesEnded = false

    view.addGestureRecognizer(tapDrawingGesture)
    card.addGestureRecognizer(panGesture)
    card.addGestureRecognizer(tapCardHandler)
  }

  func addCardViewController(controller: UIViewController) {
    contentView = controller.view
    addChildViewController(controller)
  }
}

private extension CardViewController {

  func animateCard(toState state: CardStates, thenPause pause: Bool = false) {

    cardState = state

    let animator = UIViewPropertyAnimator(duration: animationSpeed, dampingRatio: 1) { [weak self] in
      guard let strongSelf = self else { return }

      let settings = AnimationStateFactory.settingsFrom(
              state: state,
              cardSizes: strongSelf.cardSizes)

      strongSelf.bottomConstraint.constant = settings.bottomConstraint
      strongSelf.card.layer.shadowOpacity = settings.shadowOpacity
      strongSelf.card.layer.shadowRadius = settings.shadowRadius

      strongSelf.view.layoutIfNeeded()
    }

    animator.addCompletion { _ in
      self.runningAnimator = nil
    }

    if !pause { animator.startAnimation(afterDelay: 0) }
    self.runningAnimator = animator
  }

  func animateCard(pan: UIPanGestureRecognizer) {
    switch pan.state {
    case .began:
      animateCard(toState: cardState.next, thenPause: true)
    case .changed:
      let translation = pan.translation(in: view).y
      let fraction = (cardState == .context ? translation : -translation) / view.bounds.height
      runningAnimator?.fractionComplete = fraction
    case .ended:
      runningAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    default: ()
    }
  }
}
