import Foundation

public enum DevicesAPI {

    public static func registerPushToken(_ request: RegisterDeviceRequest) -> Endpoint<DeviceRegistrationResponse> {
        let payload: [String: Any] = [
            "platform": request.platform.rawValue,
            "pushToken": request.pushToken
        ]
        let data = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data("{}".utf8)

        return Endpoint(
            method: .post,
            path: "/devices",
            auth: .bearerToken,
            body: .raw(data, contentType: "application/json")
        )
    }

    public static func unregisterDevice(deviceId: String) -> Endpoint<EmptyResponse> {
        .delete(
            "/devices/\(deviceId)",
            auth: .bearerToken
        )
    }
}
