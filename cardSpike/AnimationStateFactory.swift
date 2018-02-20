import Foundation
import CoreGraphics

struct AnimationSettings {
  let bottomConstraint: CGFloat
  let shadowOpacity: Float
  let shadowRadius: CGFloat
}

struct CardSizes {
  let peek: CGSize
  let full: CGSize

  init(withFrame frame: CGRect = .zero) {
    peek = CGSize(width: 0, height: frame.height * 0.35)
    full = CGSize(width: 0, height: (frame.height * 0.9 + 20))
  }
}

struct AnimationStateFactory {

  static func settingsFrom(state: CardStates, cardSizes: CardSizes) -> AnimationSettings {
    switch state {
    case .dismissed: return AnimationSettings(bottomConstraint: cardSizes.full.height, shadowOpacity: 0, shadowRadius: 0)
    case .peek: return AnimationSettings(bottomConstraint: cardSizes.peek.height * 2, shadowOpacity: 0.1, shadowRadius: 5)
    case .full: return AnimationSettings(bottomConstraint: 20, shadowOpacity: 0.1, shadowRadius: 5)
    case .context: return AnimationSettings(bottomConstraint: cardSizes.full.height - 44, shadowOpacity: 0.1, shadowRadius: 5)
    }
  }
}
