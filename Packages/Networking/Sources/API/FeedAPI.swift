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

    /// `GET /activities/feed?page=1&limit=20`
    public static func feed(page: Int, limit: Int = 20) -> Endpoint<PaginatedResponse<ActivityPost>> {
        Endpoint(
            method: .get,
            path: "/activities/feed",
            query: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ], auth: .bearerToken
        )
    }
}
