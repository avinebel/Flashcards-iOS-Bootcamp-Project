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
    @State private var showingLoginAlert = false
    
    @State private var selectedSetToDelete: FlashcardSet?
    @State private var showingDeleteConfirmation = false

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
                        Spacer()
                        EmptySetView()
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
                                            Button(role: .destructive) {
                                                selectedSetToDelete = set
                                                showingDeleteConfirmation = true
                                            } label: {
                                                Label("Delete Set", systemImage: "trash")
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
            .navigationDestination(item: $selectedSet) { set in
                SetSharingView(set: set, authVM: authVM, setVM: setVM)
            }
            // Alert for logged out users attempting to share cloud features
            .alert("Login Required", isPresented: $showingLoginAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You must be logged in to share or make sets public, as this requires cloud storage.")
            }
            // --- Confirmation Dialog for Deletion ---
            .confirmationDialog("Delete Set?", isPresented: $showingDeleteConfirmation, presenting: selectedSetToDelete) { set in
                Button("Delete '\(set.title)'", role: .destructive) {
                    Task {
                        await authVM.deleteSet(setID: set.id.uuidString)
                        await setVM.deletePublicSet(setID: set.id.uuidString)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { set in
                Text("Are you sure you want to delete the flashcard set titled '\(set.title)'? This action cannot be undone.")
            }
        }
    }

    private func shareSet(_ set: FlashcardSet) {
        if case .signedIn = authVM.state {
            selectedSet = set
        } else {
            showingLoginAlert = true
        }
    }
}

struct SetSharingView: View {
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
    }
    
    private func saveSetChanges() {
        Task {
            await authVM.updateSet(set: editableSet)
            
            let isShared = editableSet.isPublic || editableSet.shareCode != nil
            
            if isShared {
                await setVM.saveSet(editableSet)
            } else {
                await setVM.unshareSet(setID: editableSet.id.uuidString)
            }
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(SetSharingViewModel())
}
