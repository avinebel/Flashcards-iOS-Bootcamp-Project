//
//  Flashcard.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//
import SwiftUI
import FirebaseFirestore


struct Flashcard: Identifiable, Hashable, Codable {
    var id: UUID
    var question: String
    var answer: String
    var isStarred: Bool
    
    init(
        id: String? = nil,
        question: String,
        answer: String,
        isStarred: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.isStarred = isStarred
    }
}

struct FlashcardSet: Identifiable, Hashable, Codable {
    var id: UUID
    var title: String
    var colorHex: String?
    var updatedAt: Date
    var cards: [Flashcard]
    var isPublic: Bool
    var shareCode: String?
    var ownerId: String?
    
    var cardCount: Int { cards.count }

    var color: Color {
        Color(hex: colorHex ?? "000000")
    }
    
    init(
        id: String? = nil,
        title: String,
        color: Color,
        updatedAt: Date = .now,
        cards: [Flashcard] = [],
        isPublic: Bool = false,
        shareCode: String? = nil,
        ownerId: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.colorHex = color.toHex()
        self.updatedAt = updatedAt
        self.cards = cards
        self.isPublic = isPublic
        self.shareCode = shareCode
        self.ownerId = ownerId
    }
}

extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        
        guard let components = uiColor.cgColor.components,
              components.count >= 3 else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
    
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: cleaned).scanHexInt64(&int)
        
        let r, g, b: Double
        switch cleaned.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            
            self.init(red: r, green: g, blue: b)
        
        default:
            self = .white
        }
    }
}

struct SampleData {
    static var sets: [FlashcardSet] = [
        .init(
            id: "00001",
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
            id: "00002",
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
            id: "00003",
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
            id: "00004",
            title: "New Sets",
            color: .gray,
            updatedAt: .now.addingTimeInterval(-3600*5),
            cards: [
                
            ]
        )
    ]
}
