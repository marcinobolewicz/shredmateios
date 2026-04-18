@testable import Profile
import Networking
import Common
import XCTest

// MARK: - Mocks

private enum TestError: Error {
    case notImplemented
    case simulated
}

private final class MockMentorSlotsService: MentorSlotsServiceProtocol, @unchecked Sendable {
    var generateSlotsResult: Result<GenerateSlotsResponse, Error> = .failure(TestError.notImplemented)
    private(set) var generateSlotsCallCount = 0
    private(set) var lastGenerateRequest: GenerateSlotsRequest?

    func generateSlots(request: GenerateSlotsRequest) async throws -> GenerateSlotsResponse {
        generateSlotsCallCount += 1
        lastGenerateRequest = request
        return try generateSlotsResult.get()
    }

    func fetchSlots(mentorRiderId: String, from: String?, to: String?, limit: Int) async throws -> MentorSlotsResponse {
        throw TestError.notImplemented
    }
    func fetchMySlots() async throws -> MentorSlotsResponse { throw TestError.notImplemented }
    func fetchBookedByMe() async throws -> MentorSlotsResponse { throw TestError.notImplemented }
    func cancelBooking(id: String) async throws -> MentorSlot { throw TestError.notImplemented }
    func completeSession(id: String, recommend: Bool) async throws -> MentorSlot { throw TestError.notImplemented }
    func deleteSlot(id: String) async throws { throw TestError.notImplemented }
}

private final class MockPlacesService: PlacesServiceProtocol, @unchecked Sendable {
    var fetchPlacesResult: Result<[PlaceDto], Error> = .success([])
    private(set) var fetchPlacesCallCount = 0

    func fetchPlaces(sportSlug: String?) async throws -> [PlaceDto] {
        fetchPlacesCallCount += 1
        return try fetchPlacesResult.get()
    }

    func fetchPlaceRiders(placeId: UUID, sportSlug: String?, sportId: UUID?) async throws -> [PlaceRiderPresence] {
        throw TestError.notImplemented
    }
    func joinPlace(placeId: UUID, sportId: UUID, role: PlaceRiderRole, rating: Int?) async throws -> PlaceJoinResponse {
        throw TestError.notImplemented
    }
    func leavePlace(placeId: UUID, sportId: UUID) async throws { throw TestError.notImplemented }
    func myMembership(placeId: UUID) async throws -> PlaceMembership? { throw TestError.notImplemented }
}

// MARK: - Test Data

private enum TestData {
    static let sportId = UUID()
    static let sport = Sport(id: sportId, name: "Snowboard", slug: "snowboard")

    static let otherSportId = UUID()
    static let otherSport = Sport(id: otherSportId, name: "Ski", slug: "ski")

    static let mentorRiderSport = RiderSport(
        id: "rs-1",
        sportId: sportId.uuidString,
        sport: sport,
        level: .pro,
        isMentor: true
    )

    static let nonMentorRiderSport = RiderSport(
        id: "rs-2",
        sportId: otherSportId.uuidString,
        sport: otherSport,
        level: .intermediate,
        isMentor: false
    )

    static let mentorWithoutSport = RiderSport(
        id: "rs-3",
        sportId: UUID().uuidString,
        sport: nil,
        level: .casual,
        isMentor: true
    )

    static let place = PlaceDto(id: UUID(), name: "Test Park")
    static let place2 = PlaceDto(id: UUID(), name: "Snow Valley")

    static let successResponse = GenerateSlotsResponse(generated: 5, skipped: 0)
    static let partialResponse = GenerateSlotsResponse(
        generated: 3,
        skipped: 2,
        skippedSlots: [
            .init(startTime: "2026-04-07T14:00:00", endTime: "2026-04-07T15:00:00"),
            .init(startTime: "2026-04-08T14:00:00", endTime: "2026-04-08T15:00:00")
        ]
    )
}

// MARK: - GenerateSlotsViewModel Tests

@MainActor
final class GenerateSlotsViewModelTests: XCTestCase {

    private var slotsService: MockMentorSlotsService!
    private var placesService: MockPlacesService!

    override func setUp() async throws {
        slotsService = MockMentorSlotsService()
        placesService = MockPlacesService()
    }

    private func makeSUT(
        riderSports: [RiderSport] = [TestData.mentorRiderSport, TestData.nonMentorRiderSport]
    ) -> GenerateSlotsViewModel {
        GenerateSlotsViewModel(
            mentorSlotsService: slotsService,
            placesService: placesService,
            riderSports: riderSports
        )
    }

    // MARK: - Initialization

    func testInit_filtersMentorSportsOnly() {
        let sut = makeSUT(riderSports: [TestData.mentorRiderSport, TestData.nonMentorRiderSport])

        XCTAssertEqual(sut.mentorSports.count, 1)
        XCTAssertEqual(sut.mentorSports.first?.id, TestData.sportId)
    }

    func testInit_noMentorSports_emptyList() {
        let sut = makeSUT(riderSports: [TestData.nonMentorRiderSport])

        XCTAssertTrue(sut.mentorSports.isEmpty)
    }

    func testInit_mentorWithoutSportObject_excluded() {
        let sut = makeSUT(riderSports: [TestData.mentorWithoutSport])

        XCTAssertTrue(sut.mentorSports.isEmpty)
    }

    func testInit_multipleMentorSports_allIncluded() {
        let secondMentor = RiderSport(
            id: "rs-4",
            sportId: TestData.otherSportId.uuidString,
            sport: TestData.otherSport,
            level: .pro,
            isMentor: true
        )
        let sut = makeSUT(riderSports: [TestData.mentorRiderSport, secondMentor])

        XCTAssertEqual(sut.mentorSports.count, 2)
        XCTAssertNil(sut.selectedSport)
    }

    func testInit_defaultFormState() {
        let sut = makeSUT()

        // Single mentor sport is auto-selected
        XCTAssertEqual(sut.selectedSport?.id, TestData.sportId)
        XCTAssertNil(sut.selectedPlace)
        XCTAssertTrue(sut.selectedWeekdays.isEmpty)
        XCTAssertEqual(sut.datePreset, .nextWeek)
        XCTAssertEqual(sut.duration, .sixty)
        XCTAssertEqual(sut.priceText, "150")
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertNil(sut.actionError)
        XCTAssertNil(sut.result)
        XCTAssertNil(sut.validationError)
    }

    // MARK: - Load Places

    func testLoadPlaces_success_updatesPlaces() async {
        placesService.fetchPlacesResult = .success([TestData.place, TestData.place2])
        let sut = makeSUT()

        await sut.loadPlaces()

        XCTAssertEqual(sut.places.count, 2)
        XCTAssertEqual(sut.places.first?.name, "Test Park")
    }

    func testLoadPlaces_serviceError_setsEmptyArray() async {
        placesService.fetchPlacesResult = .failure(TestError.simulated)
        let sut = makeSUT()

        await sut.loadPlaces()

        XCTAssertTrue(sut.places.isEmpty)
    }

    func testLoadPlaces_callsServiceOnce() async {
        let sut = makeSUT()

        await sut.loadPlaces()

        XCTAssertEqual(placesService.fetchPlacesCallCount, 1)
    }

    // MARK: - Weekday Helpers

    func testToggleWeekday_addsDay() {
        let sut = makeSUT()

        sut.toggleWeekday(1)

        XCTAssertTrue(sut.selectedWeekdays.contains(1))
    }

    func testToggleWeekday_removesDay() {
        let sut = makeSUT()
        sut.toggleWeekday(1)

        sut.toggleWeekday(1)

        XCTAssertFalse(sut.selectedWeekdays.contains(1))
    }

    func testToggleWeekday_multipleSelections() {
        let sut = makeSUT()

        sut.toggleWeekday(1)
        sut.toggleWeekday(3)
        sut.toggleWeekday(5)

        XCTAssertEqual(sut.selectedWeekdays, [1, 3, 5])
    }

    func testSelectWorkdays_setsMonToFri() {
        let sut = makeSUT()

        sut.selectWorkdays()

        XCTAssertEqual(sut.selectedWeekdays, [1, 2, 3, 4, 5])
    }

    func testSelectAllDays_setsAllSeven() {
        let sut = makeSUT()

        sut.selectAllDays()

        XCTAssertEqual(sut.selectedWeekdays, [0, 1, 2, 3, 4, 5, 6])
    }

    func testSelectWorkdays_overwritesPreviousSelection() {
        let sut = makeSUT()
        sut.selectAllDays()

        sut.selectWorkdays()

        XCTAssertEqual(sut.selectedWeekdays, [1, 2, 3, 4, 5])
        XCTAssertFalse(sut.selectedWeekdays.contains(0))
        XCTAssertFalse(sut.selectedWeekdays.contains(6))
    }

    func testToggleWeekday_afterSelectAll_removesDay() {
        let sut = makeSUT()
        sut.selectAllDays()

        sut.toggleWeekday(0)

        XCTAssertEqual(sut.selectedWeekdays, [1, 2, 3, 4, 5, 6])
    }

    // MARK: - Validation: No Sport

    func testGenerate_withoutSport_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedWeekdays = [1, 2]

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertNil(sut.result)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    // MARK: - Validation: No Weekdays

    func testGenerate_withoutWeekdays_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    // MARK: - Validation: Time Range

    func testGenerate_invalidTimeRange_fromAfterTo_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.timeFrom = DateComponents(hour: 18, minute: 0)
        sut.timeTo = DateComponents(hour: 14, minute: 0)

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    func testGenerate_equalTimes_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.timeFrom = DateComponents(hour: 14, minute: 0)
        sut.timeTo = DateComponents(hour: 14, minute: 0)

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    // MARK: - Validation: Price

    func testGenerate_zeroPrice_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.priceText = "0"

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    func testGenerate_emptyPrice_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.priceText = ""

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    func testGenerate_nonNumericPrice_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.priceText = "abc"

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    func testGenerate_negativePrice_setsValidationError() async {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        sut.priceText = "-50"

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    // MARK: - Validation Priority

    func testGenerate_multipleMissing_showsSportErrorFirst() async {
        let sut = makeSUT()
        // No sport, no weekdays, zero price

        await sut.generate()

        XCTAssertNotNil(sut.validationError)
        XCTAssertEqual(slotsService.generateSlotsCallCount, 0)
    }

    // MARK: - Validation Clears on Retry

    func testGenerate_clearsOldValidationErrorBeforeValidation() async {
        let sut = makeSUT()
        sut.validationError = "Previous error"
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1]
        slotsService.generateSlotsResult = .success(TestData.successResponse)

        await sut.generate()

        XCTAssertNil(sut.validationError)
    }

    // MARK: - Successful Generation

    func testGenerate_success_setsResult() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertNotNil(sut.result)
        XCTAssertEqual(sut.result?.generated, 5)
        XCTAssertEqual(sut.result?.skipped, 0)
    }

    func testGenerate_success_noActionError() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertNil(sut.actionError)
    }

    func testGenerate_success_isSubmittingResets() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertFalse(sut.isSubmitting)
    }

    func testGenerate_partialSuccess_setsResultWithSkipped() async {
        slotsService.generateSlotsResult = .success(TestData.partialResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertEqual(sut.result?.generated, 3)
        XCTAssertEqual(sut.result?.skipped, 2)
        XCTAssertEqual(sut.result?.skippedSlots.count, 2)
    }

    // MARK: - Request Building

    func testGenerate_requestContainsSportId() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertEqual(
            slotsService.lastGenerateRequest?.sportId,
            TestData.sportId.uuidString.lowercased()
        )
    }

    func testGenerate_requestContainsSortedWeekdays() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.selectedWeekdays = [5, 1, 3]

        await sut.generate()

        XCTAssertEqual(slotsService.lastGenerateRequest?.weekdays, [1, 3, 5])
    }

    func testGenerate_requestPriceInGrosz() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.priceText = "200"

        await sut.generate()

        XCTAssertEqual(slotsService.lastGenerateRequest?.price, 20000)
    }

    func testGenerate_requestDuration() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.duration = .thirty

        await sut.generate()

        XCTAssertEqual(slotsService.lastGenerateRequest?.duration, 30)
    }

    func testGenerate_withPlace_includesPlaceId() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.selectedPlace = TestData.place

        await sut.generate()

        XCTAssertEqual(
            slotsService.lastGenerateRequest?.placeId,
            TestData.place.id.uuidString.lowercased()
        )
    }

    func testGenerate_withoutPlace_placeIdIsNil() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.selectedPlace = nil

        await sut.generate()

        XCTAssertNil(slotsService.lastGenerateRequest?.placeId)
    }

    func testGenerate_requestTimeFormatted() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()
        sut.timeFrom = DateComponents(hour: 9, minute: 30)
        sut.timeTo = DateComponents(hour: 17, minute: 45)

        await sut.generate()

        XCTAssertEqual(slotsService.lastGenerateRequest?.timeFrom, "09:30")
        XCTAssertEqual(slotsService.lastGenerateRequest?.timeTo, "17:45")
    }

    func testGenerate_requestDateRangePopulated() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        let request = slotsService.lastGenerateRequest
        XCTAssertNotNil(request?.startDate)
        XCTAssertNotNil(request?.endDate)
        XCTAssertFalse(request!.startDate.isEmpty)
        XCTAssertFalse(request!.endDate.isEmpty)
    }

    // MARK: - Service Error

    func testGenerate_serviceError_setsActionError() async {
        slotsService.generateSlotsResult = .failure(TestError.simulated)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertNotNil(sut.actionError)
    }

    func testGenerate_serviceError_resultRemainsNil() async {
        slotsService.generateSlotsResult = .failure(TestError.simulated)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertNil(sut.result)
    }

    func testGenerate_serviceError_isSubmittingResets() async {
        slotsService.generateSlotsResult = .failure(TestError.simulated)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertFalse(sut.isSubmitting)
    }

    func testGenerate_serviceCallsOnce() async {
        slotsService.generateSlotsResult = .success(TestData.successResponse)
        let sut = makeValidSUT()

        await sut.generate()

        XCTAssertEqual(slotsService.generateSlotsCallCount, 1)
    }

    // MARK: - Helpers

    private func makeValidSUT() -> GenerateSlotsViewModel {
        let sut = makeSUT()
        sut.selectedSport = TestData.sport
        sut.selectedWeekdays = [1, 2, 3]
        sut.timeFrom = DateComponents(hour: 14, minute: 0)
        sut.timeTo = DateComponents(hour: 18, minute: 0)
        sut.priceText = "150"
        return sut
    }
}

// MARK: - DateRangePreset Tests

@MainActor
final class DateRangePresetTests: XCTestCase {

    func testThisWeek_returnsDateRangeStrings() {
        let range = DateRangePreset.thisWeek.dateRange()

        XCTAssertFalse(range.start.isEmpty)
        XCTAssertFalse(range.end.isEmpty)
        XCTAssertLessThanOrEqual(range.start, range.end)
    }

    func testNextWeek_startsAfterThisWeek() {
        let thisWeek = DateRangePreset.thisWeek.dateRange()
        let nextWeek = DateRangePreset.nextWeek.dateRange()

        XCTAssertGreaterThan(nextWeek.start, thisWeek.end)
    }

    func testThisAndNext_coversFullRange() {
        let thisWeek = DateRangePreset.thisWeek.dateRange()
        let nextWeek = DateRangePreset.nextWeek.dateRange()
        let both = DateRangePreset.thisAndNext.dateRange()

        XCTAssertEqual(both.start, thisWeek.start)
        XCTAssertEqual(both.end, nextWeek.end)
    }

    func testThisWeek_spansSixDays() {
        let range = DateRangePreset.thisWeek.dateRange()
        let dayDiff = daysBetween(range.start, range.end)

        XCTAssertEqual(dayDiff, 6)
    }

    func testNextWeek_spansSixDays() {
        let range = DateRangePreset.nextWeek.dateRange()
        let dayDiff = daysBetween(range.start, range.end)

        XCTAssertEqual(dayDiff, 6)
    }

    func testThisAndNext_spansThirteenDays() {
        let range = DateRangePreset.thisAndNext.dateRange()
        let dayDiff = daysBetween(range.start, range.end)

        XCTAssertEqual(dayDiff, 13)
    }

    func testAllCases_returnsThreePresets() {
        XCTAssertEqual(DateRangePreset.allCases.count, 3)
    }

    // MARK: - Helpers

    private func daysBetween(_ startStr: String, _ endStr: String) -> Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let start = fmt.date(from: startStr),
              let end = fmt.date(from: endStr) else {
            XCTFail("Invalid date format: \(startStr) or \(endStr)")
            return -1
        }
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? -1
    }
}

// MARK: - SlotDuration Tests

final class SlotDurationTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(SlotDuration.thirty.rawValue, 30)
        XCTAssertEqual(SlotDuration.sixty.rawValue, 60)
    }

    func testLabels() {
        XCTAssertEqual(SlotDuration.thirty.label, "30 min")
        XCTAssertEqual(SlotDuration.sixty.label, "60 min")
    }

    func testAllCases_returnsTwo() {
        XCTAssertEqual(SlotDuration.allCases.count, 2)
    }

    func testIdentifiable_usesRawValue() {
        XCTAssertEqual(SlotDuration.thirty.id, 30)
        XCTAssertEqual(SlotDuration.sixty.id, 60)
    }
}

// MARK: - Weekday Static Data Tests

@MainActor
final class WeekdayStaticTests: XCTestCase {

    func testWeekdays_hasSevenEntries() {
        XCTAssertEqual(GenerateSlotsViewModel.weekdays.count, 7)
    }

    func testWeekdays_startsWithMonday() {
        XCTAssertEqual(GenerateSlotsViewModel.weekdays.first?.id, 1)
    }

    func testWeekdays_endsWithSunday() {
        XCTAssertEqual(GenerateSlotsViewModel.weekdays.last?.id, 0)
    }

    func testWeekdays_containsAllIds() {
        let ids = Set(GenerateSlotsViewModel.weekdays.map(\.id))
        XCTAssertEqual(ids, [0, 1, 2, 3, 4, 5, 6])
    }

    func testWeekdays_displayOrder() {
        let ids = GenerateSlotsViewModel.weekdays.map(\.id)
        XCTAssertEqual(ids, [1, 2, 3, 4, 5, 6, 0])
    }
}
