// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShredMate",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "Login", targets: ["Login"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "Places", targets: ["Places"]),
        .library(name: "Conversations", targets: ["Conversations"])
    ],
    targets: [
        // Core Package
        .target(
            name: "Core",
            path: "Packages/Core/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Packages/Core/Tests"
        ),
        
        // Networking Package
        .target(
            name: "Networking",
            path: "Packages/Networking/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"],
            path: "Packages/Networking/Tests"
        ),
        
        // Auth Package
        .target(
            name: "Auth",
            dependencies: ["Core"],
            path: "Packages/Auth/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: ["Auth"],
            path: "Packages/Auth/Tests"
        ),
        
        // Login Package
        .target(
            name: "Login",
            dependencies: ["Core", "Networking"],
            path: "Packages/Login/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "LoginTests",
            dependencies: ["Login"],
            path: "Packages/Login/Tests"
        ),
        
        // App Package
        .target(
            name: "App",
            dependencies: ["Core", "Networking", "Auth", "Login", "Profile", "Places", "Conversations"],
            path: "Packages/App/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"],
            path: "Packages/App/Tests"
        ),
        
        // Profile Package
        .target(
            name: "Profile",
            dependencies: ["Core", "Networking"],
            path: "Packages/Profile/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ProfileTests",
            dependencies: ["Profile"],
            path: "Packages/Profile/Tests"
        ),
        
        // Places Package
        .target(
            name: "Places",
            dependencies: ["Core", "Networking"],
            path: "Packages/Places/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PlacesTests",
            dependencies: ["Places"],
            path: "Packages/Places/Tests"
        ),
        
        // Conversations Package
        .target(
            name: "Conversations",
            dependencies: ["Core", "Networking", "Auth"],
            path: "Packages/Conversations/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ConversationsTests",
            dependencies: ["Conversations"],
            path: "Packages/Conversations/Tests"
        )
    ]
)
