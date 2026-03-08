import Foundation

public protocol PushDeviceStorageProtocol: Sendable {
    func saveAPNSToken(_ token: String) async
    func loadAPNSToken() async -> String?
    func saveDeviceId(_ deviceId: String) async
    func loadDeviceId() async -> String?
    func clearDeviceId() async
}

public actor PushDeviceStorage: PushDeviceStorageProtocol {
    private let defaults: UserDefaults
    private let apnsTokenKey = "com.shredmate.push.apnsToken"
    private let deviceIdKey = "com.shredmate.push.deviceId"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func saveAPNSToken(_ token: String) async {
        defaults.set(token, forKey: apnsTokenKey)
    }

    public func loadAPNSToken() async -> String? {
        defaults.string(forKey: apnsTokenKey)
    }

    public func saveDeviceId(_ deviceId: String) async {
        defaults.set(deviceId, forKey: deviceIdKey)
    }

    public func loadDeviceId() async -> String? {
        defaults.string(forKey: deviceIdKey)
    }

    public func clearDeviceId() async {
        defaults.removeObject(forKey: deviceIdKey)
    }
}
