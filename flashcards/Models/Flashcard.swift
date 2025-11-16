//
//  Flashcard.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//
import SwiftUI

struct Flashcard: Identifiable, Hashable {
    let id: UUID
    var question: String
    var answer: String
    var isStarred: Bool
    
    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        isStarred: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.isStarred = isStarred
    }
}

struct FlashcardSet: Identifiable, Hashable {
    let id: UUID
    var title: String
    var color: Color
    var updatedAt: Date
    var cards: [Flashcard]
    var isPublic: Bool
    var shareCode: String?
    var ownerId: String?
    
    var cardCount: Int { cards.count }

    init(id: UUID = UUID(), 
         title: String, 
         color: Color, 
         updatedAt: Date = .now, 
         cards: [Flashcard] = [],
         isPublic: Bool = false,
         shareCode: String? = nil,
         ownerId: String? = nil) {
        self.id = id
        self.title = title
        self.color = color
        self.updatedAt = updatedAt
        self.cards = cards
        self.isPublic = isPublic
        self.shareCode = shareCode
        self.ownerId = ownerId
    }
}

struct SampleData {
    static var sets: [FlashcardSet] = [
        .init(
            title: "English Words",
            color: .blue,
            updatedAt: .now.addingTimeInterval(-3600*24*1),
            cards: [
                Flashcard(question: "Abandon", answer: "To give up completely"),
                Flashcard(question: "Brisk", answer: "Quick and active"),
                Flashcard(question: "Candid", answer: "Truthful and straightforward")
            ]
        ),
        .init(
            title: "Computer Science",
            color: .green,
            updatedAt: .now.addingTimeInterval(-3600*24*3),
            cards: [
                Flashcard(question: "Encapsulation", answer: "Bundling data and methods that operate on that data"),
                Flashcard(question: "Polymorphism", answer: "Ability of objects to take many forms"),
                Flashcard(question: "Inheritance", answer: "Mechanism to derive new classes from existing ones")
            ]
        ),
        .init(
            title: "SwiftUI",
            color: .orange,
            updatedAt: .now.addingTimeInterval(-3600*24*5),
            cards: [
                Flashcard(question: "State", answer: "A source of truth for a view"),
                Flashcard(question: "Binding", answer: "A two-way connection between data and UI"),
                Flashcard(question: "ViewModifier", answer: "A type that modifies the appearance or behavior of a view")
            ]
        ),
        .init(
            title: "New Sets",
            color: .gray,
            updatedAt: .now.addingTimeInterval(-3600*5),
            cards: [
                
            ]
        )
    ]
}

extension Color {
    // Convert Color to hex string
    var hex: String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    // Create Color from hex string
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6 else { return nil }
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

