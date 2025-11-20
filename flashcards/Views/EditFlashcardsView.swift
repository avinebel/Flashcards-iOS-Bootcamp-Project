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
                    await authVM.updateSet(set: set)
                    if case .signedIn = authVM.state, set.isPublic {
                        await setVM.saveSet(set)
                    }
                }
            }
        }
        .navigationTitle("Edit Cards")
        .toolbar {
            NavigationLink {
                FlashcardFormView(set: $set)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
