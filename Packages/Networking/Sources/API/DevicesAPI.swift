import Foundation

public enum DevicesAPI {

    public static func registerPushToken(_ request: RegisterDeviceRequest) -> Endpoint<DeviceRegistrationResponse> {
        Endpoint(
            method: .post,
            path: "/devices",
            auth: .bearerToken,
            body: .json(request, keys: .camelCase)
        )
    }

    public static func unregisterDevice(deviceId: String) -> Endpoint<EmptyResponse> {
        .delete(
            "/devices/\(deviceId)",
            auth: .bearerToken
        )
    }
}
