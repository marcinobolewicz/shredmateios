import Foundation

public enum MentorsAPI {

    public static func mentors(
        sportId: UUID? = nil,
        placeId: UUID? = nil,
        page: Int = 1,
        limit: Int = 20
    ) -> Endpoint<PaginatedResponse<MentorListItem>> {
        var query: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let sportId {
            query.append(URLQueryItem(name: "sportId", value: sportId.uuidString.lowercased()))
        }
        if let placeId {
            query.append(URLQueryItem(name: "placeId", value: placeId.uuidString.lowercased()))
        }
        return .get("/riders/mentors", query: query, auth: .bearerToken)
    }
}
