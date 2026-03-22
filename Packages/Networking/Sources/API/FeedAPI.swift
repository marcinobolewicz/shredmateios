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

    /// `POST /activities/photo`
    public static func uploadPhoto(imageData: Data, fileName: String = "photo.jpg") -> Endpoint<ActivityPhotoUploadResponse> {
        .uploadMultipart(
            "/activities/photo",
            multipart: MultipartFormData(
                fileData: imageData,
                fileName: fileName,
                mimeType: "image/jpeg",
                fieldName: "file"
            ),
            auth: .bearerToken
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

    /// `DELETE /activities/:activityId`
    public static func deleteActivity(activityId: String) -> Endpoint<EmptyResponse> {
        Endpoint(
            method: .delete,
            path: "/activities/\(activityId)",
            auth: .bearerToken
        )
    }

    /// `GET /activities/rider/:riderId?page=1&limit=20`
    public static func riderFeed(riderId: String, page: Int, limit: Int = 20) -> Endpoint<PaginatedResponse<ActivityPost>> {
        Endpoint(
            method: .get,
            path: "/activities/rider/\(riderId)",
            query: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ], auth: .bearerToken
        )
    }
}
