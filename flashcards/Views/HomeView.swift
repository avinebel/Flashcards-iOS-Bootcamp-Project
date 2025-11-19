//
//  ContentView.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI
import FirebaseAuth

// Home View

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var setVM: SetSharingViewModel
    
    private let grid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    private var isLoading: Bool {
        // Assume authVM has an isLoading property or check AuthState
        if case .loading = authVM.state {
            return true
        }
        return false
    }
    
    @State private var selectedSet: FlashcardSet?
    @State private var showingSharingOptions = false
    @State private var showingLoginAlert = false

    var body: some View {
        let mySets = authVM.getFlashcardSets()
        NavigationStack {
            HStack {
                Spacer()
                NavigationLink(
                    destination: CreateSetView()
                        .environmentObject(authVM)
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3)
                }
            }
            .padding(.horizontal, 15)
            Group {
                if isLoading {
                    ProgressView("Loading User Data...")
                        .padding(.top, 30)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if mySets.isEmpty {
                    VStack {
                        Text("No sets. Create a new set to get started!")
                            .padding(.top, 30)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: grid, spacing: 16) {
                            ForEach(mySets) { set in
                                NavigationLink(destination: FlashcardView(set: set)) {
                                    SetCardView(set: set)
                                        .contextMenu {
                                            Button {
                                                shareSet(set)
                                            } label: {
                                                Label("Share Set", systemImage: "square.and.arrow.up")
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
            .sheet(isPresented: $showingSharingOptions) {
                if let initialSet = selectedSet {
                    SetSharingSheetContent(
                        set: initialSet,
                        authVM: authVM,
                        setVM: setVM
                    )
                    .presentationDetents([.height(250)])
                }
            }
            // Alert for logged out users attempting to share cloud features
            .alert("Login Required", isPresented: $showingLoginAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You must be logged in to share or make sets public, as this requires cloud storage.")
            }
        }
    }

    private func shareSet(_ set: FlashcardSet) {
        if case .signedIn = authVM.state {
            selectedSet = set
            showingSharingOptions = true
        } else {
            showingLoginAlert = true
        }
    }
}

struct SetSharingSheetContent: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var editableSet: FlashcardSet
    
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var setVM: SetSharingViewModel
    
    init(set: FlashcardSet, authVM: AuthViewModel, setVM: SetSharingViewModel) {
        self._editableSet = State(initialValue: set)
        self.authVM = authVM
        self.setVM = setVM
    }
    
    private var isSharingEnabled: Bool {
        if case .signedIn = authVM.state {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isSharingEnabled {
                        // --- Controls visible and enabled when signed in ---
                        Toggle(
                            "Make Set Public",
                            isOn: $editableSet.isPublic
                        )
                        .onChange(of: editableSet.isPublic) {
                            saveSetChanges()
                        }

                        if editableSet.isPublic {
                            Button("Generate Share Code") {
                                editableSet.shareCode = setVM.generateShareCode()
                                saveSetChanges()
                            }

                            // Display Share Code
                            if let shareCode = editableSet.shareCode {
                                HStack {
                                    Text("Share Code:")
                                    Spacer()
                                    Text(shareCode)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } else {
                        // --- Message when signed out ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sharing Not Available")
                                .font(.headline)
                            Text("Please sign in to link this set to your account and enable public sharing features.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Share Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func saveSetChanges() {
        Task {
            await authVM.updateSet(set: editableSet)
            
            if editableSet.isPublic {
                await setVM.saveSet(editableSet)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(SetSharingViewModel())
}
