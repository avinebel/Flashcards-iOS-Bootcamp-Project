//
//  EditFlashcardsView.swift
//  flashcards
//
//  Created by Daniel  Roldan on 11/19/25.
//

import SwiftUI

struct EditFlashcardsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var setVM: SetSharingViewModel
    @Binding var set: FlashcardSet
    
    @State private var colorPickerShow: Bool = false
    let palette: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .brown, .black, .gray
    ]
    private let columns = [
        GridItem(.fixed(35)), GridItem(.fixed(35)), GridItem(.fixed(35)), GridItem(.fixed(35))
    ]
    
    var body: some View {
        List {
            Section(header: Text("FlashCard Set")) {
                HStack {
                    TextField("Enter a title for the set", text: $set.title)
                        .font(.headline)
                        .onChange(of: set.title) {
                            saveSetChanges()
                        }
                    Button {
                        colorPickerShow = true
                    } label: {
                        Image(systemName: "circle.fill")
                            .font(.title3)
                            .foregroundStyle(set.color.opacity(0.6))
                    }
                    .sheet(isPresented: $colorPickerShow, content: {
                        VStack {
                            Text("Select Card Color")
                                .font(.headline)
                                .padding(.top)
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(palette, id: \.self) { color in
                                    Circle()
                                        .fill(color.opacity(0.6))
                                        .frame(width: 35, height: 35)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(set.color == color ? 0.6 : 0),
                                                        lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            set.colorHex = color.toHex()
                                            saveSetChanges()
                                            withAnimation(.spring(duration: 0.25)) {
                                                colorPickerShow = false
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                        .presentationDetents([.height(200), .medium])
                    })
                }
            }
            
            Section(header: Text("Flashcards")) {
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
                    Task {
                        set.cards.remove(atOffsets: indexSet)
                        saveSetChanges()
                    }
                }
            }
        }
        .navigationTitle("Edit: \(set.title)")
        .toolbar {
            NavigationLink {
                FlashcardFormView(set: $set)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private func saveSetChanges() {
        Task {
            await authVM.updateSet(set: set)
            
            let isShared = set.isPublic || set.shareCode != nil
            
            if isShared {
                await setVM.saveSet(set)
            }
        }
    }
}
