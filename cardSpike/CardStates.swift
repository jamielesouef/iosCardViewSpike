
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
