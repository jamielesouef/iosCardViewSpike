//
//  ViewController.swift
//  cardSpike
//
//  Created by Jamie Le Souef on 16/2/18.
//  Copyright © 2018 Jamie Le Souef. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

  private lazy var cardHandle: UIView = CardViewFactory.cardHandle
  private lazy var card: UIView = CardViewFactory.card
  private lazy var cardContainerView: UIView = CardViewFactory.cardContainerView
  private lazy var pin: UIButton = CardViewFactory.pin

  private let animationSpeed: TimeInterval = 0.5
  private let bottomOffset: CGFloat = 20

  private var cardState: CardStates = .dismissed
  private var bottomConstraint = NSLayoutConstraint()
  private var runningAnimator: [UIViewPropertyAnimator] = []
  private var cardPeekHeight: CGFloat = 0
  private var fullHeight: CGFloat = 0
  private var contentView: UIView!
  private var animatingToState: CardStates = .dismissed

  override func viewDidLoad() {
    super.viewDidLoad()
    setupChildViewController()
    addAllViews()
    layoutViews()
    setupTouchEvents()
  }

  @objc
  func showFullCard(recognizer: UITapGestureRecognizer) {
    // swallow the tap even so that the parent doesn't active
    // I'm sure there is a better way but ¯\_(ツ)_/¯
  }

  @objc
  func didAttemptToDismissCard(recognizer: UITapGestureRecognizer) {
    animate(toState: .dismissed)
  }

  @objc
  func didSelectPin(sender: UIButton) {
    animate(toState: .peek)
  }

  @objc
  func didPan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      let newState = cardState.next
      animate(toState: newState)
      runningAnimator.forEach { $0.pauseAnimation() }
    case .changed:
      let translation = recognizer.translation(in: card)
      var fraction = -translation.y / card.frame.height

      if cardState == .dismissed { fraction *= -1 }

      runningAnimator.first?.fractionComplete = fraction
    case .ended: ()
      runningAnimator.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }

    default: ()
    }
  }
}

private extension ViewController {
  private func addAllViews() {
    cardContainerView.addSubview(contentView)
    card.addSubview(cardContainerView)

    view.addSubview(card)
    view.addSubview(pin)

    cardContainerView.layer.masksToBounds = true
    card.addSubview(cardHandle)
    card.bringSubview(toFront: cardHandle)
    view.bringSubview(toFront: card)
  }

  private func setupChildViewController() {
    let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentNavigation")
    contentViewController.childViewControllers.first?.title = "Foo Title"
    contentView = contentViewController.view
    self.addChildViewController(contentViewController)
  }

  private func layoutViews() {

    cardPeekHeight = view.frame.height * 0.35
    fullHeight = view.frame.height * 0.95

    card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    card.heightAnchor.constraint(equalToConstant: fullHeight).isActive = true
    bottomConstraint = card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: fullHeight)
    bottomConstraint.isActive = true

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
    let tapDrawingGesture = UITapGestureRecognizer(target: self, action: #selector(didAttemptToDismissCard(recognizer:)))
    let tapCardHandler = UITapGestureRecognizer(target: self, action: #selector(showFullCard(recognizer:)))

    pin.addTarget(self, action: #selector(didSelectPin(sender:)), for: .touchUpInside)
    view.addGestureRecognizer(tapDrawingGesture)
    card.addGestureRecognizer(panGesture)
    card.addGestureRecognizer(tapCardHandler)
  }

  private func animate(toState state: CardStates) {
    if state != animatingToState {
      runningAnimator.forEach { $0.stopAnimation(true) }
      runningAnimator.removeAll()
    }

    animatingToState = state

    guard runningAnimator.isEmpty else { return }

    cardState = animatingToState

    let animator = UIViewPropertyAnimator(duration: animationSpeed, dampingRatio: 1) { [weak self] in
      guard let strongSelf = self else { return }

      let settings = AnimationStateFactory.settingsFrom(state: state,
                                                        height: strongSelf.fullHeight,
                                                        peekHeight: strongSelf.cardPeekHeight)

      strongSelf.bottomConstraint.constant = settings.bottomConstraint
      strongSelf.card.layer.shadowOpacity = settings.shadowOpacity
      strongSelf.card.layer.shadowRadius = settings.shadowRadius

      strongSelf.view.layoutIfNeeded()
    }

    animator.addCompletion { _ in
      self.runningAnimator.removeAll()
    }

    animator.startAnimation(afterDelay: 0)
    self.runningAnimator.append(animator)
  }
}
