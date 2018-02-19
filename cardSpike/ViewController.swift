//
//  ViewController.swift
//  cardSpike
//
//  Created by Jamie Le Souef on 16/2/18.
//  Copyright © 2018 Jamie Le Souef. All rights reserved.
//

import UIKit

enum CardStates {
  case dismissed, peek, full, context
}

extension CardStates {
  var next: CardStates {
    switch self {
    case .dismissed: return .peek
    case .peek: return .full
    case .full: return .context
    case .context: return .full
    }
  }
  var previous: CardStates {
    switch self {
    case .dismissed: return .dismissed
    case .peek: return .dismissed
    case .full: return .context
    case .context: return .full
    }
  }
}

class ContentViewController: UIViewController {

}

class ViewController: UIViewController {

  private lazy var cardHandle: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.lightGray
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    return view
  }()

  private lazy var card: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var cardContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var pin: UIButton = {
    let view = UIButton()
    view.backgroundColor = UIColor.orange
    view.layer.shadowOpacity = 0.1
    view.layer.shadowRadius = 2
    view.layer.cornerRadius = 15
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private var cardState: CardStates = .dismissed
  private let animationSpeed: TimeInterval = 0.5
  private var bottomConstraint = NSLayoutConstraint()
  private var heightConstraint = NSLayoutConstraint()
  private var runningAnimators: [UIViewPropertyAnimator] = []
  private var cardPeekHeight: CGFloat = 0
  private var fullHeight: CGFloat = 0
  private let bottomOffset: CGFloat = 20
  private let padding: CGFloat = 0
  private var contentView: UIView!
  private var animatingToState: CardStates = .dismissed

  override func viewDidLoad() {
    super.viewDidLoad()
    cardPeekHeight = view.frame.height * 0.35
    fullHeight = view.frame.height * 0.95
    let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentNavigation")
    contentViewController.childViewControllers.first?.title = "Foo Title"
    contentView = contentViewController.view

    cardContainerView.addSubview(contentView)
    card.addSubview(cardContainerView)
    self.addChildViewController(contentViewController)
    view.addSubview(card)
    view.addSubview(pin)

    cardContainerView.layer.masksToBounds = true
    card.addSubview(cardHandle)
    card.bringSubview(toFront: cardHandle)

    layout()
    setupTouchEvents()

    view.bringSubview(toFront: card)
  }

  private func layout() {
    bottomConstraint = card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: fullHeight)
    bottomConstraint.isActive = true

    card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    heightConstraint = card.heightAnchor.constraint(equalToConstant: fullHeight)
    heightConstraint.isActive = true

    cardContainerView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 0).isActive = true
    cardContainerView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: 0).isActive = true
    cardContainerView.topAnchor.constraint(equalTo: card.topAnchor, constant: 0).isActive = true
    cardContainerView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: 0).isActive = true

    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 0).isActive = true
    contentView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: 0).isActive = true
    contentView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 0).isActive = true
    contentView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 0).isActive = true

    pin.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    pin.widthAnchor.constraint(equalToConstant: 30).isActive = true
    pin.heightAnchor.constraint(equalToConstant: 30).isActive = true
    pin.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true

    cardHandle.topAnchor.constraint(equalTo: card.topAnchor, constant: 6).isActive = true
    cardHandle.widthAnchor.constraint(equalToConstant: 50).isActive = true
    cardHandle.heightAnchor.constraint(equalToConstant: 10).isActive = true
    cardHandle.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
  }

  private func setupTouchEvents() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
    let tapDrawingGesture = UITapGestureRecognizer(target: self, action: #selector(didAttemptToDissmissCard(recognizer:)))
    let tapCardHandler = UITapGestureRecognizer(target: self, action: #selector(showFullCard(recognizer:)))

    pin.addTarget(self, action: #selector(didSelectPin(sender:)), for: .touchUpInside)
    view.addGestureRecognizer(tapDrawingGesture)
    card.addGestureRecognizer(panGesture)
    card.addGestureRecognizer(tapCardHandler)
  }

  @objc
  func showFullCard(recognizer: UITapGestureRecognizer) {
//    animate(toState: .full)
  }

  @objc
  func didAttemptToDissmissCard(recognizer: UITapGestureRecognizer) {
    animate(toState: .dismissed)
  }

  @objc
  func didSelectPin(sender: UIButton) {
    animate(toState: .peek)
  }

  private func animate(toState state: CardStates) {
    if state != animatingToState {
      runningAnimators.forEach { $0.stopAnimation(true) }
      runningAnimators.removeAll()
    }

    animatingToState = state

    guard runningAnimators.isEmpty else { return }

    cardState = animatingToState

    let animator = UIViewPropertyAnimator(duration: animationSpeed, dampingRatio: 1) { [weak self] in
      guard let strongSelf = self else { return }
      switch state {
      case .dismissed:
        strongSelf.bottomConstraint.constant = strongSelf.fullHeight
        strongSelf.card.layer.shadowOpacity = 0
        strongSelf.card.layer.shadowRadius = 0

      case .peek:
        strongSelf.bottomConstraint.constant = strongSelf.cardPeekHeight * 2
        strongSelf.card.layer.shadowOpacity = 0.1
        strongSelf.card.layer.shadowRadius = 5
      case .full:
        strongSelf.bottomConstraint.constant = 20
        strongSelf.card.layer.shadowOpacity = 0.1
        strongSelf.card.layer.shadowRadius = 5
      case .context:
        strongSelf.bottomConstraint.constant = strongSelf.fullHeight - 44
        strongSelf.card.layer.shadowOpacity = 0.1
        strongSelf.card.layer.shadowRadius = 5
      }

      strongSelf.view.layoutIfNeeded()
    }

    animator.addCompletion { _ in
      self.runningAnimators.removeAll()
    }

    animator.startAnimation(afterDelay: 0)
    self.runningAnimators.append(animator)
  }

  @objc
  func didPan(recognizer: UIPanGestureRecognizer) {


    var newState: CardStates = .full
    switch recognizer.state {
    case .began:
      newState = cardState.next
      animate(toState: newState)
      runningAnimators.forEach { $0.pauseAnimation() }

    case .changed:
      let translation = recognizer.translation(in: card)
      var fraction = -translation.y / card.frame.height

      if cardState == .dismissed { fraction *= -1 }

      runningAnimators.first?.fractionComplete = fraction
    case .ended: ()
      let velocity = recognizer.velocity(in: card).y
      let shouldClose = velocity > 0
      print("Pan Ended with velocity \(velocity)")
      runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }

    default: ()
    }
  }
}
