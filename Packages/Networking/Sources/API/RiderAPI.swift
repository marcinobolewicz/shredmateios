//
//  RiderAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

public enum RiderAPI {
    
    // MARK: - All Riders

    /// Lists all riders.
    ///
    /// `GET /riders`
    public static func all() -> Endpoint<[Rider]> {
        .get("/riders", auth: .bearerToken)
    }

    // MARK: - Profile
    public static func me() -> Endpoint<Rider> {
        .get("/riders/me", auth: .bearerToken)
    }
    
    public static func updateMe(_ request: UpdateRiderRequest) -> Endpoint<Rider> {
        Endpoint(
            method: .patch,
            path: "/riders/me",
            auth: .bearerToken,
            body: .json(request, keys: .camelCase)
        )
    }
    
    public static func uploadAvatar(imageData: Data, fileName: String = "avatar.jpg", mimeType: String = "image/jpeg") -> Endpoint<AvatarUploadResponse> {
        .uploadMultipart(
            "/riders/me/avatar",
            multipart: MultipartFormData(
                fileData: imageData,
                fileName: fileName,
                mimeType: mimeType,
                fieldName: "file"
            ),
            auth: .bearerToken
        )
    }
    
    public static func deleteMe() -> Endpoint<EmptyResponse> {
        .delete("/riders/me", auth: .bearerToken)
    }
    
    // MARK: - Base Location

    public static func baseLocation() -> Endpoint<RiderBaseLocation> {
        .get("/riders/me/base-location", auth: .bearerToken)
    }
    
    public static func updateBaseLocation(_ request: UpdateBaseLocationRequest) -> Endpoint<RiderBaseLocation> {
        Endpoint(
            method: .put,
            path: "/riders/me/base-location",
            auth: .bearerToken,
            body: .json(UpdateBaseLocationRequestDTO(request: request), keys: .camelCase)
        )
    }
    
    // MARK: - Sports
    
    public static func sports() -> Endpoint<[RiderSport]> {
        .get("/riders/me/sports", auth: .bearerToken)
    }
    
    public static func upsertSport(sportId: String, request: UpsertRiderSportRequest) -> Endpoint<RiderSport> {
        .post("/riders/me/sports/\(sportId)", body: request, auth: .bearerToken)
    }
    
    public static func deleteSport(sportId: String) -> Endpoint<EmptyResponse> {
        .delete("/riders/me/sports/\(sportId)", auth: .bearerToken)
    }

}
