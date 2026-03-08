import Foundation

public enum PushPlatform: String, Codable, Sendable {
    case ios = "IOS"
}

public struct RegisterDeviceRequest: Codable, Sendable {
    public let platform: PushPlatform
    public let pushToken: String

    public init(platform: PushPlatform = .ios, pushToken: String) {
        self.platform = platform
        self.pushToken = pushToken
    }
}

public struct DeviceRegistrationResponse: Decodable, Sendable {
    public let deviceId: String?

    public init(deviceId: String?) {
        self.deviceId = deviceId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let direct =
            try container.decodeIfPresent(String.self, forKey: .deviceId)
            ?? container.decodeIfPresent(String.self, forKey: .id) {
            self.deviceId = direct
            return
        }

        if let nested = try container.decodeIfPresent(NestedDevice.self, forKey: .data) {
            self.deviceId = nested.deviceId ?? nested.id
            return
        }

        self.deviceId = nil
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case deviceId
        case data
    }

    private struct NestedDevice: Decodable {
        let id: String?
        let deviceId: String?
    }
}
