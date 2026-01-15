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
        .library(name: "Login", targets: ["Login"])
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
            dependencies: ["Core"],
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
            dependencies: ["Core", "Networking", "Login"],
            path: "Packages/App/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"],
            path: "Packages/App/Tests"
        )
    ]
)
