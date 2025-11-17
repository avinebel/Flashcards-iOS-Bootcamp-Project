//
//  ContentView.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI

// Home View

struct HomeView: View {
    @State private var sets: [FlashcardSet] = SampleData.sets
    @EnvironmentObject var setVM: SetSharingViewModel
    private let grid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                NavigationLink(
                    destination: CreateSetView()
                        .environmentObject(setVM)
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3)
                }
                //                NavigationLink {
                //                    CreateSetView { newSet in
                //                        sets.insert(newSet, at: 0)   // <-- updates UI instantly
                //                    }
                //                } label: {
                //                    Image(systemName: "plus.circle.fill")
                //                        .font(.title)
                //                        .foregroundStyle(.white)
                //                        .shadow(color: .black.opacity(0.6), radius: 3)
                //                }

            }
            .padding(.horizontal, 15)
            Group {
                if setVM.isLoading {
                    // Show loading indicator while fetching
                    ProgressView()
                        .padding(.top, 30)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if setVM.mySets.isEmpty {
                    // Empty state
                    VStack {
                        Text("No sets. Create a new set to get started!")
                            .padding(.top, 30)
                        Spacer()
                    }
                } else {
                    // Show sets
                    ScrollView {
                        LazyVGrid(columns: grid, spacing: 16) {
                            ForEach(setVM.mySets) { set in
                                NavigationLink(
                                    destination: FlashcardView(set: set)
                                ) {
                                    SetCardView(set: set)
                                        .contextMenu {
                                            Button {
                                                shareSet(set)
                                            } label: {
                                                Label(
                                                    "Share Set",
                                                    systemImage:
                                                        "square.and.arrow.up"
                                                )
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                Task {
                    await setVM.fetchMySets()
                }
            }
            .sheet(isPresented: $showingSharingOptions) {
                if let set = selectedSet {
                    NavigationStack {
                        Form {
                            Section {
                                Toggle(
                                    "Make Set Public",
                                    isOn: Binding(
                                        get: { set.isPublic },
                                        set: { newValue in
                                            if let index = sets.firstIndex(
                                                where: { $0.id == set.id })
                                            {
                                                sets[index].isPublic = newValue
                                                Task {
                                                    await sharingVM.saveSet(
                                                        sets[index]
                                                    )
                                                }
                                            }
                                        }
                                    )
                                )

                                if set.isPublic {
                                    Button("Generate Share Code") {
                                        if let index = sets.firstIndex(where: {
                                            $0.id == set.id
                                        }) {
                                            sets[index].shareCode =
                                                sharingVM.generateShareCode()
                                            Task {
                                                await sharingVM.saveSet(
                                                    sets[index]
                                                )
                                            }
                                        }
                                    }

                                    if let shareCode = set.shareCode {
                                        HStack {
                                            Text("Share Code:")
                                            Spacer()
                                            Text(shareCode)
                                                .font(
                                                    .system(
                                                        .body,
                                                        design: .monospaced
                                                    )
                                                )
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Share Set")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            Button("Done") {
                                showingSharingOptions = false
                            }
                        }
                    }
                    .presentationDetents([.height(250)])
                }
            }

        }
    }

    @StateObject private var sharingVM = SetSharingViewModel()
    @State private var selectedSet: FlashcardSet?
    @State private var showingSharingOptions = false

    private func addSet() {
        let new = FlashcardSet(title: "New Set", color: .accentColor, cards: [])
        withAnimation(.spring) {
            sets.insert(new, at: 0)
        }
    }

    private func shareSet(_ set: FlashcardSet) {
        selectedSet = set
        showingSharingOptions = true
    }
}

#Preview {
    let vm: SetSharingViewModel = SetSharingViewModel()
    //    vm.mySets = [SampleData.sets.first!]

    return HomeView()
        .environmentObject(vm)
}
