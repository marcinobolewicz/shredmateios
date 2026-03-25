import SwiftUI
import Networking

public struct MentorsRootView: View {
    private let mentorsService: MentorsServiceProtocol
    private let sportsService: SportsServiceProtocol
    private let placesService: PlacesServiceProtocol
    private let riderService: RiderServiceProtocol
    private let mentorSlotsService: MentorSlotsServiceProtocol
    private let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    @State private var router = PlacesRouter()

    public init(
        mentorsService: MentorsServiceProtocol,
        sportsService: SportsServiceProtocol,
        placesService: PlacesServiceProtocol,
        riderService: RiderServiceProtocol,
        mentorSlotsService: MentorSlotsServiceProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.mentorsService = mentorsService
        self.sportsService = sportsService
        self.placesService = placesService
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.onOpenChat = onOpenChat
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            MentorsView(
                mentorsService: mentorsService,
                sportsService: sportsService,
                placesService: placesService
            )
            .placesDestinations(
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                onOpenChat: onOpenChat
            )
        }
        .environment(router)
    }
}
