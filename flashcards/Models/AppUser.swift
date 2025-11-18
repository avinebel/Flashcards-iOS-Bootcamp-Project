//
//  User.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/17/25.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String?
    var flashcardSets: [FlashcardSet]
    
    init(
        id: String? = nil,
        email: String,
        displayName: String? = nil,
        flashcardSets: [FlashcardSet] = []
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.flashcardSets = flashcardSets
    }
}
