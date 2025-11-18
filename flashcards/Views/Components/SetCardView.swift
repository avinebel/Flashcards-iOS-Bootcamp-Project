//
//  SetCardView.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/10/25.
//

// Card Set
import SwiftUI

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
