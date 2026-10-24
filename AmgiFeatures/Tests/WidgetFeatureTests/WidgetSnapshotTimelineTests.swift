import Foundation
import Testing
import WidgetKit
@testable import AppCore
@testable import WidgetFeature

struct WidgetSnapshotTimelineTests {
    private struct Fixture {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let now: Date
        let provider: WidgetTimelineProvider
        let intent: AmgiWidgetIntent

        func file(_ id: Int64) -> URL { directory.appendingPathComponent("widget-snapshot-\(id).json") }

        init(deckIDs: [Int64]) throws {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let dir = directory
            let read: @Sendable (Int64) -> WidgetSnapshot? = {
                WidgetSnapshotStore.read(from: dir.appendingPathComponent("widget-snapshot-\($0).json"))
            }
            now = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 10, hour: 12)))
            provider = WidgetTimelineProvider(snapshotForDeck: read)
            let intent = AmgiWidgetIntent()
            intent.deck = DeckEntity(id: "42", name: "Japanese")
            self.intent = intent
            let forecast = WidgetSnapshot.Forecast(rolloverHour: 4, dayZero: AnkiDay.start(of: now, rolloverHour: 4), days: [
                .init(newCount: 4, learnCount: 2, reviewCount: 3),
                .init(newCount: 4, learnCount: 0, reviewCount: 11),
            ])
            for id in deckIDs {
                try WidgetSnapshotStore.write(WidgetSnapshot(
                    deckId: id, deckName: id == 0 ? "All Decks" : "Japanese",
                    newCount: 4, learnCount: 2, reviewCount: 3, reviewedToday: 7,
                    streak: 5, lastSevenDays: [1, 2, 3, 4, 5, 6, 7],
                    snapshotDate: now, forecast: forecast
                ), to: file(id))
            }
        }

        func cleanup() { try? FileManager.default.removeItem(at: directory) }
    }

    private func expectForecast(_ timeline: Timeline<WidgetEntry>, deckId: Int64) {
        #expect(timeline.entries.map(\.snapshot.deckId) == [deckId, deckId])
        #expect(timeline.entries.map(\.snapshot.reviewCount) == [3, 11])
        #expect(timeline.entries.map(\.snapshot.reviewedToday) == [7, 0])
        #expect(timeline.policy == .atEnd)
    }

    @Test
    func presentDeckRendersItsOwnForecast() throws {
        let fixture = try Fixture(deckIDs: [0, 42])
        defer { fixture.cleanup() }
        expectForecast(fixture.provider.timeline(for: fixture.intent, now: fixture.now), deckId: 42)
    }

    @Test
    func deletedDeckFallsBackToAllDecks() throws {
        let fixture = try Fixture(deckIDs: [0, 42])
        defer { fixture.cleanup() }
        try FileManager.default.removeItem(at: fixture.file(42))
        expectForecast(fixture.provider.timeline(for: fixture.intent, now: fixture.now), deckId: 0)
    }

    @Test
    func noSnapshotsYieldsPlaceholderAndBacksOffAnHour() throws {
        let fixture = try Fixture(deckIDs: [])
        defer { fixture.cleanup() }
        let timeline = fixture.provider.timeline(for: fixture.intent, now: fixture.now)
        #expect(timeline.entries.count == 1)
        #expect(timeline.policy == .after(fixture.now.addingTimeInterval(3600)))
    }
}
