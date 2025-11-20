//
//  FlashcardFormView.swift
//  flashcards
//
//  Created by Daniel  Roldan on 11/19/25.
//

import SwiftUI

struct FlashcardFormView: View {
    @Binding var set: FlashcardSet
    var card: Flashcard? = nil

    @State private var questionText: String = ""
    @State private var answerText: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Question")) {
                TextField("Enter question", text: $questionText)
            }
            
            Section(header: Text("Answer")) {
                TextField("Enter answer", text: $answerText)
            }
        }
        .navigationTitle(card == nil ? "Add Card" : "Edit Card")
        .toolbar {
            Button("Save") {
                saveCard()
                dismiss()
            }
        }
        .onAppear {
            if let card = card {
                questionText = card.question
                answerText = card.answer
            }
        }
    }
    
    private func saveCard() {
        if let card = card,
           let index = set.cards.firstIndex(where: { $0.id == card.id }) {
            set.cards[index].question = questionText
            set.cards[index].answer = answerText
        } else {
            let newCard = Flashcard(question: questionText, answer: answerText)
            set.cards.append(newCard)
        }
        
        set.updatedAt = .now
    }
}
