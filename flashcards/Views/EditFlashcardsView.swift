//
//  EditFlashcardsView.swift
//  flashcards
//
//  Created by Daniel  Roldan on 11/19/25.
//

import SwiftUI

struct EditFlashcardsView: View {
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
                set.cards.remove(atOffsets: indexSet)
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
