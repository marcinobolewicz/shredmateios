# Profile Services Documentation

This document describes the services, clients, and data contracts used in the Profile feature of ShredMate iOS.

## Overview

The Profile feature allows authenticated users to view and edit their rider profile, including:
- Basic info (display name, description, rider type)
- Avatar image
- Base location (home resort/area)
- Sports with skill levels and mentor status

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      ProfileView                             │
│                          │                                   │
│                    ProfileViewModel                          │
│                          │                                   │
├─────────────────────────────────────────────────────────────┤
│                    RiderServiceProtocol                      │
│                          │                                   │
│                      RiderService                            │
│                          │                                   │
│                    AuthHTTPClient                            │
│                          │                                   │
│                      TokenStorage                            │
└─────────────────────────────────────────────────────────────┘
```

## Services

### RiderService

**Location**: `Packages/Auth/Sources/Services/RiderService.swift`

Actor-based service for all rider profile operations. Conforms to `RiderServiceProtocol` for testability.

#### Profile Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `fetchMyRider()` | `GET /riders/me` | Fetch current user's rider profile |
| `updateMyRider(_:)` | `PATCH /riders/me` | Update profile fields |
| `uploadAvatar(_:)` | `POST /riders/me/avatar` | Upload avatar image (multipart) |
| `deleteMyAccount()` | `DELETE /riders/me` | Delete user account |

#### Base Location Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `fetchMyBaseLocation()` | `GET /riders/me/base-location` | Get base location (returns nil if not set) |
| `updateMyBaseLocation(_:)` | `PUT /riders/me/base-location` | Set/update base location |

#### Sports Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `fetchAllSports()` | `GET /sports` | Get list of all available sports |
| `fetchMyRiderSports()` | `GET /riders/me/sports` | Get user's sports with levels |
| `upsertMyRiderSport(sportId:request:)` | `POST /riders/me/sports/:sportId` | Add or update a sport |
| `deleteMyRiderSport(sportId:)` | `DELETE /riders/me/sports/:sportId` | Remove a sport |

### AuthHTTPClient

**Location**: `Packages/Auth/Sources/Networking/AuthHTTPClient.swift`

Actor-based HTTP client with automatic token injection and 401 refresh handling.

**Features**:
- Automatic `Authorization: Bearer <token>` header for protected endpoints
- Single-flight token refresh (parallel requests wait for one refresh)
- Session invalidation callback on refresh failure
- Multipart upload support for avatars

### TokenStorage

**Location**: `Packages/Auth/Sources/Storage/TokenStorage.swift`

Keychain-based secure storage for authentication tokens and user data.

## Data Models

### Rider

```swift
public struct Rider: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let type: RiderType           // .rider, .mentor, .both
    public let displayName: String?      // max 40 chars
    public let description: String?      // max 1000 chars
    public let avatarUrl: String?
    public let createdAt: Date
    public let updatedAt: Date
}
```

### RiderType

```swift
public enum RiderType: String, Codable, Sendable, CaseIterable {
    case rider = "RIDER"
    case mentor = "MENTOR"
    case both = "BOTH"
}
```

### RiderBaseLocation

```swift
public struct RiderBaseLocation: Codable, Sendable, Equatable {
    public let latitude: Double    // -90 to 90
    public let longitude: Double   // -180 to 180
    public let name: String?       // optional location name
}
```

### Sport

```swift
public struct Sport: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let icon: String?
}
```

### RiderSport

```swift
public struct RiderSport: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let sportId: String
    public let sport: Sport?
    public let level: SkillLevel   // .beginner, .intermediate, .advanced, .expert
    public let isMentor: Bool      // available as mentor for this sport
}
```

### SkillLevel

```swift
public enum SkillLevel: String, Codable, Sendable, CaseIterable {
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case expert = "EXPERT"
}
```

## Request Models

### UpdateRiderRequest

```swift
public struct UpdateRiderRequest: Codable, Sendable {
    public let type: RiderType?
    public let displayName: String?
    public let description: String?
}
```

### UpdateBaseLocationRequest

```swift
public struct UpdateBaseLocationRequest: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let name: String?
}
```

### UpsertRiderSportRequest

```swift
public struct UpsertRiderSportRequest: Codable, Sendable {
    public let level: SkillLevel
    public let isMentor: Bool
}
```

## Flow

### App Initialization

1. `AppSetup.configure()` creates `AuthHTTPClient`, `TokenStorage`, services
2. `AuthState.restoreSession()` checks for stored session
3. If valid tokens exist, fetches current user and rider profile
4. UI shows Home if logged in, Auth flow otherwise

### Profile Loading

1. User navigates to ProfileView
2. `ProfileViewModel.loadProfile()` is called
3. Parallel fetch of rider profile, base location, and sports
4. Fields populated from fetched data

### Profile Update

1. User edits fields in ProfileView
2. Validation runs (display name required, max lengths)
3. `ProfileViewModel.saveProfile()` calls `RiderService.updateMyRider()`
4. On success, `AuthState.fetchRiderProfile()` refreshes global state

### Avatar Upload

1. User selects image (PhotosPicker - not yet implemented)
2. Image converted to JPEG Data
3. `RiderService.uploadAvatar()` sends multipart POST
4. Response contains new `avatarUrl`
5. Local rider updated, global state refreshed

### Sports Management

1. Sports list loaded on profile open
2. Each sport row shows current level/mentor status if set
3. Upsert sends POST to `/riders/me/sports/:sportId`
4. Delete sends DELETE to same endpoint
5. Per-sport loading spinners (not full-page)

## Error Handling

- Network errors show user-friendly alert
- 401 triggers automatic token refresh
- Refresh failure clears session, returns to login
- Non-critical failures (base location, sports) don't block profile view

## Backend URL

```
Base URL: https://api.shredmate.eu/api/v1
```

All endpoints are relative to this base URL.
