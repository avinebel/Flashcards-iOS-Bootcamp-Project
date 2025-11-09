//
//  ContentView.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI

// Home View

struct HomeView: View {
    @State private var sets: [FlashcardSet] = SampleData.sets
    private let grid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Card Sets
                LazyVGrid(columns: grid, spacing: 16) {
                    ForEach(sets) { set in
                        NavigationLink(destination: FlashcardView(set: set)) {
                            SetCardView(set: set)
                                .contextMenu {
                                    Button {
                                        shareSet(set)
                                    } label: {
                                        Label("Share Set", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showingSharingOptions) {
                if let set = selectedSet {
                    NavigationStack {
                        Form {
                            Section {
                                Toggle("Make Set Public", isOn: Binding(
                                    get: { set.isPublic },
                                    set: { newValue in
                                        if let index = sets.firstIndex(where: { $0.id == set.id }) {
                                            sets[index].isPublic = newValue
                                            Task {
                                                await sharingVM.saveSet(sets[index])
                                            }
                                        }
                                    }
                                ))
                                
                                if set.isPublic {
                                    Button("Generate Share Code") {
                                        if let index = sets.firstIndex(where: { $0.id == set.id }) {
                                            sets[index].shareCode = sharingVM.generateShareCode()
                                            Task {
                                                await sharingVM.saveSet(sets[index])
                                            }
                                        }
                                    }
                                    
                                    if let shareCode = set.shareCode {
                                        HStack {
                                            Text("Share Code:")
                                            Spacer()
                                            Text(shareCode)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Share Set")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            Button("Done") {
                                showingSharingOptions = false
                            }
                        }
                    }
                    .presentationDetents([.height(250)])
                }
            }
        }
    }
    
    @StateObject private var sharingVM = SetSharingViewModel()
    @State private var selectedSet: FlashcardSet?
    @State private var showingSharingOptions = false
    
    private func addSet() {
        let new = FlashcardSet(title: "New Set", color: .accentColor, cards: [])
        withAnimation(.spring) {
            sets.insert(new, at: 0)
        }
    }
    
    private func shareSet(_ set: FlashcardSet) {
        selectedSet = set
        showingSharingOptions = true
    }
}

// Card Set
struct SetCardView: View {
    let set: FlashcardSet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(set.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                // Show how many cards in the set
                Label("\(set.cardCount)", systemImage: "square.on.square")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                // Show last update
                Text(set.updatedAt, format: .relative(presentation: .named))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(set.color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    HomeView()
}
