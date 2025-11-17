import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class SetSharingViewModel: ObservableObject {
    @Published var publicSets: [FlashcardSet] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    // Generate a random 6-character share code
    func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    // Save a set to Firestore
    func saveSet(_ set: FlashcardSet) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var setData: [String: Any] = [
            "title": set.title,
            "color": "blue", // Store as a simple string since Color isn't directly serializable
            "updatedAt": set.updatedAt,
            "isPublic": set.isPublic,
            "ownerId": userId,
            "cards": set.cards.map { [
                "question": $0.question,
                "answer": $0.answer,
                "isStarred": $0.isStarred
            ]}
        ]
        
        if let shareCode = set.shareCode {
            setData["shareCode"] = shareCode
        }
        
        do {
            try await db.collection("flashcardSets").addDocument(data: setData)
        } catch {
            errorMessage = "Failed to save set: \(error.localizedDescription)"
        }
    }
    
    // Fetch public sets
    func fetchPublicSets() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("flashcardSets")
                .whereField("isPublic", isEqualTo: true)
                .getDocuments()
            
            publicSets = snapshot.documents.compactMap { doc -> FlashcardSet? in
                guard let title = doc.data()["title"] as? String,
                      let colorString = doc.data()["color"] as? String,
                      let updatedAt = (doc.data()["updatedAt"] as? Timestamp)?.dateValue(),
                      let isPublic = doc.data()["isPublic"] as? Bool,
                      let ownerId = doc.data()["ownerId"] as? String,
                      let cardsData = doc.data()["cards"] as? [[String: Any]] else {
                    return nil
                }
                
                let cards = cardsData.compactMap { cardData -> Flashcard? in
                    guard let question = cardData["question"] as? String,
                          let answer = cardData["answer"] as? String,
                          let isStarred = cardData["isStarred"] as? Bool else {
                        return nil
                    }
                    return Flashcard(question: question, answer: answer, isStarred: isStarred)
                }
                
                return FlashcardSet(
                    title: title,
                    color: .blue, // Default to blue since we can't reliably serialize Color
                    updatedAt: updatedAt,
                    cards: cards,
                    isPublic: isPublic,
                    shareCode: doc.data()["shareCode"] as? String,
                    ownerId: ownerId
                )
            }
        } catch {
            errorMessage = "Failed to fetch public sets: \(error.localizedDescription)"
        }
    }
    
    // Import a set using share code
    func importSet(withCode code: String) async -> Bool {
        do {
            let snapshot = try await db.collection("flashcardSets")
                .whereField("shareCode", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else {
                errorMessage = "No set found with this code"
                return false
            }
            
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue(),
                  let isPublic = data["isPublic"] as? Bool,
                  let ownerId = data["ownerId"] as? String,
                  let cardsData = data["cards"] as? [[String: Any]] else {
                errorMessage = "Invalid set data"
                return false
            }
            
            let cards = cardsData.compactMap { cardData -> Flashcard? in
                guard let question = cardData["question"] as? String,
                      let answer = cardData["answer"] as? String,
                      let isStarred = cardData["isStarred"] as? Bool else {
                    return nil
                }
                return Flashcard(question: question, answer: answer, isStarred: isStarred)
            }
            let newSet = FlashcardSet(
                title: title,
                color: .blue,
                updatedAt: .now,
                cards: cards,
                isPublic: false,
                shareCode: nil,
                ownerId: Auth.auth().currentUser?.uid
            )
            
            await saveSet(newSet)
            return true
        } catch {
            errorMessage = "Failed to import set: \(error.localizedDescription)"
            return false
        }
    }
}
