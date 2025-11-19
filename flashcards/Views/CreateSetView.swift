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
    @EnvironmentObject var authVM: AuthViewModel
    
    @State var title: String = ""
    @State var isPublic: Bool = false
    @State var cards: [Flashcard] = [Flashcard(question: "", answer: "")]
    @State var selectedColor: Color = .blue
    @State var colorPickerShow: Bool = false
    
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
                TextField("Untitled Set", text: $title)
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
//            ScrollView {
//                ForEach($cards) { $card in
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .frame(height: 60)
//                            .foregroundStyle(.white)
//                        HStack {
//                            TextField("Term", text: $card.question)
//                            Divider()
//                                .frame(width: 2, height: 50)
//                            TextField("Definition", text: $card.answer)
//                        }
//                        .padding()
//                    }
//                }
//                Button("Add Card") {
//                    var t = Transaction()
//                    t.disablesAnimations = true
//                    withTransaction(t) {
//                        cards.append(Flashcard(question: "", answer: ""))
//                    }
//                }
//            }
//            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
            List {
                ForEach($cards) { $card in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 60)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.1), radius: 2)

                        HStack {
                            TextField("Term", text: $card.question)
                            Divider().frame(width: 2, height: 50)
                            TextField("Definition", text: $card.answer)
                        }
                        .padding()
                    }
//                    .frame(maxWidth: .infinity)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
                    .listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let i = cards.firstIndex(where: { $0.id == card.id }) {
                                cards.remove(at: i)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button("Add Card") {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) {
                            cards.append(Flashcard(question: "", answer: ""))
                        }
                    }
                    .foregroundStyle(.blue)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden) // <- Makes it look EXACTLY like ScrollView
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
        let validCards = cards.filter {
            !$0.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !$0.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let newSet = FlashcardSet(
            title: title.isEmpty ? "Untitled Set" : title,
            color: selectedColor,
            cards: validCards,
            isPublic: isPublic
        )
        authVM.addNewSet(newSet: newSet)
        if case .signedIn = authVM.state, newSet.isPublic {
            await setVM.saveSet(newSet)
        }
    }
}

#Preview {
    CreateSetView()
}
