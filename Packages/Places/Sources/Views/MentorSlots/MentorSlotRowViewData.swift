import Foundation

public struct MentorSlotRowViewData: Identifiable, Equatable, Sendable {
    public let id: String
    public let timeRange: String
    public let duration: String
    public let price: String
    public let sportName: String
    public let placeName: String?

    public init(
        id: String,
        timeRange: String,
        duration: String,
        price: String,
        sportName: String,
        placeName: String?
    ) {
        self.id = id
        self.timeRange = timeRange
        self.duration = duration
        self.price = price
        self.sportName = sportName
        self.placeName = placeName
    }
}

public struct MentorSlotDayGroup: Identifiable, Equatable, Sendable {
    public let id: String
    public let dayHeader: String
    public let slots: [MentorSlotRowViewData]

    public init(dayHeader: String, slots: [MentorSlotRowViewData]) {
        self.id = dayHeader
        self.dayHeader = dayHeader
        self.slots = slots
    }
}
