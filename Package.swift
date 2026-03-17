// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShredMate",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Common", targets: ["Common"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "Login", targets: ["Login"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "Places", targets: ["Places"]),
        .library(name: "Conversations", targets: ["Conversations"]),
        .library(name: "Theme", targets: ["Theme"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.1.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/kean/Pulse.git", from: "5.0.0")
    ],
    targets: [
        // Theme Package
        .target(
            name: "Theme",
            path: "Packages/Theme/Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ThemeTests",
            dependencies: ["Theme"],
            path: "Packages/Theme/Tests"
        ),
        
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
        
        // Common Package
        .target(
            name: "Common",
            path: "Packages/Common/Sources",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"],
            path: "Packages/Common/Tests"
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
            dependencies: ["Core", "Networking", "Theme", "Common"],
            path: "Packages/Login/Sources",
            resources: [
                .process("Resources")
            ],
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
            dependencies: [
                "Core", "Networking", "Auth", "Login", "Profile", "Places", "Conversations", "Theme",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "PulseUI", package: "Pulse")
            ],
            path: "Packages/App/Sources",
            resources: [
                .process("Resources")
            ],
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
            dependencies: ["Core", "Networking", "Common"],
            path: "Packages/Profile/Sources",
            resources: [
                .process("Resources")
            ],
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
            dependencies: ["Core", "Networking", "Common", "Theme"],
            path: "Packages/Places/Sources",
            resources: [
                .process("Resources")
            ],
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
            dependencies: [
                "Core",
                "Networking",
                "Common",
                "Theme",
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "Packages/Conversations/Sources",
            resources: [
                .process("Resources")
            ],
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
