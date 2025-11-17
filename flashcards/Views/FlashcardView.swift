//
//  FlashcardView.swift
//  flashcards
//
//  Created by Avi Nebel on 11/2/25.
//

import SwiftUI

struct FlashcardView: View {
    var set: FlashcardSet
    @State private var selection: String?
    @State private var flippedCard: String? = nil
    @State private var previousCard: String? = nil
    @Environment(\.dismiss) var dismiss
    @State private var currCardCount: Int = 1
    
    var body: some View {
        VStack {
            // Edit button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left.circle")
                        .font(.largeTitle)
                        .foregroundStyle(set.color.opacity(0.4))
                }
                Spacer()
                Button {
                    // Edit action
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.largeTitle)
                        .foregroundStyle(set.color.opacity(0.4))
                }
            }
            
            // Cards
            TabView(selection: $selection) {
                ForEach(set.cards) { card in
                    FlippableCard(
                        question: card.question,
                        answer: card.answer,
                        color: set.color,
                        isFlipped: flippedCard == card.id
                    )
                    .tag(card.id)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            flippedCard = flippedCard == card.id ? nil : card.id
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .animation(.easeInOut, value: selection)
            .onChange(of: selection) {
                if let previous = previousCard, flippedCard == previous {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        flippedCard = nil
                    }
                }
                
                if let newSelection = selection,
                   let newIndex = set.cards.firstIndex(where: { $0.id == newSelection }) {
                    currCardCount = newIndex + 1
                }
                
                previousCard = selection
            }
            
            // Navigation buttons
            HStack {
                Button {
                    moveCard(-1)
                    if (currCardCount != 1) {
                        currCardCount = currCardCount - 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .padding()
                        .foregroundStyle(Color.gray)
                        .background(Circle().fill(set.color.opacity(0.15)))
                }
                
                Spacer()
                Text("\(currCardCount)/\(set.cardCount)")
                    .foregroundStyle(set.color.opacity(0.4))
                    .font(.title)
                Spacer()
                
                Button {
                    moveCard(1)
                    if (currCardCount != set.cardCount) {
                        currCardCount = currCardCount + 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .padding()
                        .foregroundStyle(Color.gray)
                        .background(Circle().fill(set.color.opacity(0.15)))
                }
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
        }
        .padding()
        .onAppear {
            selection = set.cards.first?.id
            previousCard = selection
            currCardCount = 1
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    private func moveCard(_ offset: Int) {
        guard let current = selection,
              let index = set.cards.firstIndex(where: { $0.id == current }) else { return }
        let newIndex = index + offset
        if newIndex >= 0 && newIndex < set.cards.count {
            selection = set.cards[newIndex].id
        }
    }
}

struct FlippableCard: View {
    let question: String
    let answer: String
    let color: Color
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            if isFlipped {
                //back
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .overlay(
                        Text(answer)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                //front
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .stroke(color.opacity(0.15), lineWidth: 2.5)
                    .overlay(
                        Text(question)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .shadow(radius: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.horizontal)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
    }
}

#Preview {
    FlashcardView(set: SampleData.sets.first!)
}
