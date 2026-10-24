import AppCore
import Testing
@testable import WidgetFeature

struct WidgetConfigurationTests {
    private let empty = DeckEntityQuery(snapshots: { [] })

    @Test
    func allDecksResolvesBeforeFirstSnapshot() async throws {
        let entities = try await empty.entities(for: ["0"])
        #expect(entities.map(\.id) == ["0"])
        #expect(entities.first?.name == "All Decks")
    }

    @Test
    func unknownDeckIsOmitted() async throws {
        #expect(try await empty.entities(for: ["42", String(Int64.max), "not-a-deck"]).isEmpty)
    }
}
