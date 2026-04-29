import SwiftUI
import Networking
import Common
import Payment

/// Resolves a rider profile by **User ID** (not Rider ID), then defers to ``RiderDetailLoadingView``.
///
/// Some entry points (e.g. chat conversations) only know the user, not the rider profile id.
/// This view fills the gap by locating the matching rider, then handing off to the standard
/// rider profile screen so the experience stays consistent across the app.
///
/// - Note: Currently uses `fetchAllRiders` + filter as there is no dedicated by-user endpoint.
///   Replace with a single-rider lookup once the backend exposes one.
public struct RiderByUserLoadingView: View {
    let userId: UUID
    let displayName: String
    let riderService: any RiderServiceProtocol
    let mentorSlotsService: any MentorSlotsServiceProtocol
    let stripePaymentService: StripePaymentService?
    let onMessageTap: (_ userId: UUID, _ displayName: String) -> Void

    @State private var state: LoadState = .idle
    @State private var resolved: Rider?

    public init(
        userId: UUID,
        displayName: String,
        riderService: any RiderServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        stripePaymentService: StripePaymentService? = nil,
        onMessageTap: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.userId = userId
        self.displayName = displayName
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.stripePaymentService = stripePaymentService
        self.onMessageTap = onMessageTap
    }

    public var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                if let rider = resolved {
                    RiderDetailLoadingView(
                        partialViewData: partialViewData(from: rider),
                        riderService: riderService,
                        mentorSlotsService: mentorSlotsService,
                        stripePaymentService: stripePaymentService,
                        onMessageTap: onMessageTap
                    )
                } else {
                    notFoundView
                }

            case .failed:
                notFoundView
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadIfNeeded() }
    }

    // MARK: - Subviews

    private var notFoundView: some View {
        ContentUnavailableView(
            PlacesStrings.riderProfileUnavailableTitle.localized,
            systemImage: "person.slash",
            description: Text(PlacesStrings.riderProfileUnavailableDescription.localized)
        )
    }

    // MARK: - Loading

    private func loadIfNeeded() async {
        guard case .idle = state else { return }
        state = .loading

        do {
            let needle = userId.uuidString.lowercased()
            let riders = try await riderService.fetchAllRiders()
            resolved = riders.first { $0.userId.lowercased() == needle }
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }

    // MARK: - Mapping

    private func partialViewData(from rider: Rider) -> RiderCardViewData {
        let name = rider.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty ?? displayName

        return RiderCardViewData(
            id: rider.id,
            riderId: rider.id,
            userId: UUID(uuidString: rider.userId),
            displayName: name,
            avatarInitials: initials(from: name),
            avatarURL: rider.avatarUrl.flatMap(URL.init(string:)),
            description: rider.description ?? "",
            hasHomeLocation: false,
            isMentor: rider.type == .mentor || rider.type == .both
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
