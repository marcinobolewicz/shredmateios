import SwiftUI
import Networking

public struct MentorsRootView: View {
    private let mentorsService: MentorsServiceProtocol
    private let sportsService: SportsServiceProtocol
    private let placesService: PlacesServiceProtocol
    private let riderService: RiderServiceProtocol
    private let mentorSlotsService: MentorSlotsServiceProtocol
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol
    private let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    @State private var router = PlacesRouter()

    public init(
        mentorsService: MentorsServiceProtocol,
        sportsService: SportsServiceProtocol,
        placesService: PlacesServiceProtocol,
        riderService: RiderServiceProtocol,
        mentorSlotsService: MentorSlotsServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.mentorsService = mentorsService
        self.sportsService = sportsService
        self.placesService = placesService
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.sportPreferenceStorage = sportPreferenceStorage
        self.onOpenChat = onOpenChat
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            MentorsView(
                mentorsService: mentorsService,
                sportsService: sportsService,
                placesService: placesService,
                sportPreferenceStorage: sportPreferenceStorage
            )
            .placesDestinations(
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                sportPreferenceStorage: sportPreferenceStorage,
                onOpenChat: onOpenChat
            )
        }
        .environment(router)
    }
}
