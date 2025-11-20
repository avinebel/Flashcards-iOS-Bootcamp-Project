//
//  EditFlashcardsView.swift
//  flashcards
//
//  Created by Daniel  Roldan on 11/19/25.
//

import SwiftUI

struct EditFlashcardsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var setVM: SetSharingViewModel
    @Binding var set: FlashcardSet
    
    var body: some View {
        List {
            Section(header: Text("Set Title")) {
                TextField("Enter a title for the set", text: $set.title)
                    .font(.headline)
                    .onChange(of: set.title) {
                        saveSetChanges()
                    }
            }
            
            Section(header: Text("Flashcards")) {
                ForEach(set.cards) { card in
                    NavigationLink {
                        FlashcardFormView(set: $set, card: card)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(card.question)
                                .font(.headline)
                            Text(card.answer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    Task {
                        set.cards.remove(atOffsets: indexSet)
                        saveSetChanges()
                    }
                }
            }
        }
        .navigationTitle("Edit: \(set.title)")
        .toolbar {
            NavigationLink {
                FlashcardFormView(set: $set)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private func saveSetChanges() {
        Task {
            await authVM.updateSet(set: set)
            
            let isShared = set.isPublic || set.shareCode != nil
            
            if isShared {
                await setVM.saveSet(set)
            }
        }
    }
}
