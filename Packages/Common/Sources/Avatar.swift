import Foundation

public enum Avatar: Equatable, Hashable, Sendable {
    case image(String)
    case imageRemote(URL?)
    case initials(String)
}
