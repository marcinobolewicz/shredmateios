import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.networking", category: "PushDeviceService")

public protocol PushDeviceServiceProtocol: Sendable {
    func setAPNSToken(_ token: String) async
    func registerCurrentTokenIfPossible() async
    func unregisterCurrentDeviceIfNeeded() async
}

public actor PushDeviceService: PushDeviceServiceProtocol {
    private let client: APIClienting
    private let storage: PushDeviceStorageProtocol

    public init(client: APIClienting, storage: PushDeviceStorageProtocol) {
        self.client = client
        self.storage = storage
    }

    public func setAPNSToken(_ token: String) async {
        let previousToken = await storage.loadAPNSToken()
        await storage.saveAPNSToken(token)

        let currentDeviceId = await storage.loadDeviceId()
        let tokenChanged = previousToken != token
        let needsRegistration = tokenChanged || currentDeviceId == nil

        if tokenChanged {
            await storage.clearDeviceId()
        }

        if needsRegistration {
            await registerCurrentTokenIfPossible()
        }
    }

    public func registerCurrentTokenIfPossible() async {
        guard let token = await storage.loadAPNSToken(), !token.isEmpty else { return }

        do {
            let response = try await client.send(
                DevicesAPI.registerPushToken(RegisterDeviceRequest(pushToken: token))
            )

            if let deviceId = response.deviceId, !deviceId.isEmpty {
                await storage.saveDeviceId(deviceId)
            }
        } catch let error as NetworkError {
            // Unauthorized before login is expected; token remains cached and can be retried later.
            if case .unauthorized = error {
                return
            }
            if case .requestFailed(let statusCode) = error, statusCode == 401 {
                return
            }
            logger.error("Failed to register push token: \(error.localizedDescription)")
        } catch {
            logger.error("Failed to register push token: \(error.localizedDescription)")
        }
    }

    public func unregisterCurrentDeviceIfNeeded() async {
        guard let deviceId = await storage.loadDeviceId(), !deviceId.isEmpty else { return }

        do {
            _ = try await client.send(DevicesAPI.unregisterDevice(deviceId: deviceId))
            await storage.clearDeviceId()
        } catch let error as NetworkError {
            // Consider the device unregistered locally when backend no longer knows this id.
            if case .requestFailed(let statusCode) = error, statusCode == 404 {
                await storage.clearDeviceId()
                return
            }
            logger.error("Failed to unregister device: \(error.localizedDescription)")
        } catch {
            logger.error("Failed to unregister device: \(error.localizedDescription)")
        }
    }
}
