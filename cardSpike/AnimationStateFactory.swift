import UIKit

struct AnimationSettings {
  let bottomConstraint: CGFloat
  let shadowOpacity: Float
  let shadowRadius: CGFloat
}

struct AnimationStateFactory {
  static func settingsFrom(state: CardStates, height: CGFloat, peekHeight: CGFloat) -> AnimationSettings {
    switch state {
    case .dismissed: return AnimationSettings(bottomConstraint: height, shadowOpacity: 0, shadowRadius: 0)
    case .peek: return AnimationSettings(bottomConstraint: peekHeight * 2, shadowOpacity: 0.1, shadowRadius: 5)
    case .full: return AnimationSettings(bottomConstraint: 20, shadowOpacity: 0.1, shadowRadius: 5)
    case .context: return AnimationSettings(bottomConstraint: height - 44, shadowOpacity: 0.1, shadowRadius: 5)
    }
  }
}
