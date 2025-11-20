import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class SetSharingViewModel: ObservableObject {
    @Published var publicSets: [FlashcardSet] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var mySets: [FlashcardSet] = []
    
    let PUBLICSET_DOC = "publicSets"
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
        let docRef = db.collection(PUBLICSET_DOC).document(set.id.uuidString)
        do {
            try docRef.setData(from: set)   // FlashcardSet is Codable, so we can directly pass it into Firebase
        } catch {
            errorMessage = "Failed to save set: \(error.localizedDescription)"
            print("SetSharingViewModel: Error saving set \(set.id.uuidString): \(error.localizedDescription)")
        }
    }
    
    // Fetch public sets
    func fetchPublicSets() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection(PUBLICSET_DOC)
                .whereField("isPublic", isEqualTo: true)
                .getDocuments()
            
            self.publicSets = snapshot.documents.compactMap { doc -> FlashcardSet? in
                do {
                    return try doc.data(as: FlashcardSet.self)
                } catch {
                    print("Error decoding public set \(doc.documentID): \(error.localizedDescription)")
                    return nil
                }
            }
        } catch {
            errorMessage = "Failed to fetch public sets: \(error.localizedDescription)"
            print("SetSharingViewModel: Error fetching public sets: \(error.localizedDescription)")
        }
    }
    
    // Import a set using share code
    func importSet(withCode code: String) async -> FlashcardSet? {
        do {
            let snapshot = try await db.collection(PUBLICSET_DOC)
                .whereField("shareCode", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else {
                errorMessage = "No set found with this code"
                return nil
            }
            
            let sharedSet = try doc.data(as: FlashcardSet.self)
            return makePersonalCopy(from: sharedSet)
        } catch {
            errorMessage = "Failed to import set: \(error.localizedDescription)"
            print("SetSharingViewModel: Error importing set: \(error.localizedDescription)")
            return nil
        }
    }

    /// Creates a private copy of a public set to add to the user's account or local storage.
    func makePersonalCopy(from publicSet: FlashcardSet) -> FlashcardSet {
        let ownerId = Auth.auth().currentUser?.uid
        let copiedCards = publicSet.cards.map {
            Flashcard(
                question: $0.question,
                answer: $0.answer,
                isStarred: $0.isStarred
            )
        }

        return FlashcardSet(
            id: UUID(),
            title: publicSet.title,
            color: publicSet.color,
            updatedAt: .now,
            cards: copiedCards,
            isPublic: false,
            shareCode: nil,
            ownerId: ownerId
        )
    }
    
    func unshareSet(setID: String) async {
        let docRef = db.collection(PUBLICSET_DOC).document(setID)
        
        let updateFields: [String: Any] = [
            "isPublic": false,
        ]
        
        do {
            try await docRef.updateData(updateFields)
            publicSets.removeAll { $0.id.uuidString == setID }
        } catch {
            errorMessage = "Failed to unshare set: \(error.localizedDescription)"
            print("SetSharingViewModel: Error unsharing set \(setID): \(error.localizedDescription)")
        }
    }
    
    func deletePublicSet(setID: String) async {
        let docRef = db.collection(PUBLICSET_DOC).document(setID)
        
        do {
            try await docRef.delete()
            publicSets.removeAll { $0.id.uuidString == setID }
        } catch {
            print("SetSharingViewModel: Error deleting public set \(setID): \(error.localizedDescription)")
        }
    }

    @MainActor
    func fetchMySets() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await db.collection(PUBLICSET_DOC)
                .whereField("ownerId", isEqualTo: userId)
                .getDocuments()

            mySets = snapshot.documents.compactMap { doc -> FlashcardSet? in
                do {
                    return try doc.data(as: FlashcardSet.self)
                } catch {
                    print("Error decoding user's public set \(doc.documentID): \(error.localizedDescription)")
                    return nil
                }
            }

        } catch {
            errorMessage = "Failed to fetch your sets: \(error.localizedDescription)"
            print("SetSharingViewModel: Error fetching user's public sets: \(error.localizedDescription)")
        }
    }

}
