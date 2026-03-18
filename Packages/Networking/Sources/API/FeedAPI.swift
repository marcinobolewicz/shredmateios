import Foundation

public enum FeedAPI {

    /// `POST /activities`
    public static func createActivity(_ request: CreateActivityRequest) -> Endpoint<ActivityPost> {
        Endpoint(
            method: .post,
            path: "/activities",
            auth: .bearerToken,
            body: .json(request, keys: .camelCase)
        )
    }
}
