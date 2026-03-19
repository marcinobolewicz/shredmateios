import Foundation
import Networking

public enum FeedRoute: Hashable {
    case createPost
    case placeDetails(ActivityPostPlace)
    case riderDetails(ActivityPostRider)
}
