//
//  FindReplaceModel.swift
//  BrowseFeature
//
//  Created by Vladimir Gusev on 22.10.2026.
//

import AnkiClients
import AnkiKit
import Dependencies
import Foundation

@Observable
@MainActor
final class FindReplaceModel {
    enum Outcome: Equatable {
        case updated(Int)
        case undone
        case failed(String)
    }

    // Empty means the whole collection.
    let noteIDs: [NoteID]
    var fieldNames: [String] = []
    var find = ""
    var replacement = ""
    // Empty means every field.
    var fieldName = ""
    var useRegex = false
    var matchCase = false
    var isWorking = false
    var outcome: Outcome?
    var canUndo = false

    @ObservationIgnored @Dependency(\.noteClient) private var noteClient
    @ObservationIgnored @Dependency(\.cardClient) private var cardClient
    @ObservationIgnored @Dependency(\.notetypesClient) private var notetypesClient

    init(noteIDs: [NoteID]) {
        self.noteIDs = noteIDs
    }

    var canApply: Bool { !find.isEmpty && !isWorking }

    func loadFieldNames() async {
        guard !noteIDs.isEmpty else {
            fieldNames = (try? await wholeCollectionFieldNames()) ?? []
            return
        }
        fieldNames = (try? await noteClient.fieldNamesForNotes(noteIDs)) ?? []
    }

    func apply() async {
        guard canApply else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            let count = try await noteClient.findAndReplace(
                noteIDs, find, replacement, useRegex, matchCase, fieldName
            )
            outcome = .updated(count)
            canUndo = count > 0
        } catch {
            // The engine wraps regex parse errors in <pre> tags.
            let message = error.localizedDescription
                .replacing(/<\/?pre>/, with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            outcome = .failed(message)
            canUndo = false
        }
    }

    func undo() async {
        guard canUndo, !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await cardClient.undoLast()
            outcome = .undone
        } catch {
            outcome = .failed(error.localizedDescription)
        }
        canUndo = false
    }

    private func wholeCollectionFieldNames() async throws -> [String] {
        var names: [String] = []
        for entry in try await notetypesClient.listAll() {
            for field in try await notetypesClient.get(entry.id).fields where !names.contains(field.name) {
                names.append(field.name)
            }
        }
        return names.sorted()
    }
}
