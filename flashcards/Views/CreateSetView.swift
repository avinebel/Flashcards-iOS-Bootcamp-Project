//
//  CreateSetView.swift
//  flashcards
//
//  Created by Avi Nebel on 11/11/25.
//

import SwiftUI
import FirebaseAuth

struct CreateSetView: View {
    var onSave: (FlashcardSet) -> Void = { _ in }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var setVM: SetSharingViewModel
    
    @State var setName: String = "Untitled Set"
    @State private var selectedColor: Color = .blue
    @State var colorPickerShow: Bool = false
    @State var term: String = ""
    @State var definition: String = ""
    @State var cards: [Flashcard] = [Flashcard(id: UUID(), question: "", answer: "", isStarred: false)]
    
    let palette: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple,
            .pink, .brown, .black, .gray, .white
        ]
    
    private let columns = [
        GridItem(.fixed(35)), GridItem(.fixed(35)), GridItem(.fixed(35)), GridItem(.fixed(35))
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Untitled Set", text: $setName)
                    .font(.title)
                Spacer()
                Button {
                    colorPickerShow = true;
                } label: {
                    Image(systemName: "circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(selectedColor.opacity(0.4))
                }
                .sheet(isPresented: $colorPickerShow, content: {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(palette, id: \.self) { color in
                            Circle()
                                .fill(color.opacity(0.6))
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(selectedColor == color ? 0.6 : 0),
                                                lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    withAnimation(.spring(duration: 0.25)) {
                                        colorPickerShow = false
                                    }
                                }
                        }
                    }
                    .presentationDetents([.height(200), .medium])
                })
                Spacer()
            }
            ScrollView {
                ForEach($cards) { $card in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: .infinity, height: 60)
                            .foregroundStyle(.white)
                        HStack {
                            TextField("Term", text: $card.question)
                            Divider()
                                .frame(width: 2, height: 50)
                            TextField("Definition", text: $card.answer)
                        }
                        .padding()
                    }
                }
                Button("Add Card") {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        $cards.wrappedValue.append(Flashcard(id: UUID(), question: "", answer: "", isStarred: false))
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 200, height: 40)
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                    .padding()
                    
                    Divider()
                        .frame(width: 2, height: 30)
                    
                    Button("Done") {
                        Task {
                            await saveSet()
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .padding()
                }
            }
        }
        .padding()
    }
    
    func saveSet() async {
        let actualCards = cards.filter { !$0.question.isEmpty || !$0.answer.isEmpty }
        let newSet : FlashcardSet = FlashcardSet(id: UUID(), title: setName, color: selectedColor, updatedAt: Date(), cards: actualCards, isPublic: true, shareCode: nil, ownerId: Auth.auth().currentUser?.uid)
        onSave(newSet)
        await setVM.saveSet(newSet)
        
    }
}

#Preview {
    CreateSetView()
}
