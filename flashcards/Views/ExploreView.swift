import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var setVM: SetSharingViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showingImportSheet = false
    @State private var importCode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if setVM.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(setVM.publicSets) { set in
                            NavigationLink(value: set) {
                                SetCardView(set: set)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    download(set: set)
                                } label: {
                                    Label("Download", systemImage: "arrow.down.circle.fill")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Explore Sets")
            .navigationDestination(for: FlashcardSet.self) { set in
                PublicSetDetailView(set: set)
            }
            .toolbar {
                Button {
                    showingImportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                NavigationStack {
                    Form {
                        Section("Import Set") {
                            TextField("Enter Set Code", text: $importCode)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        Section {
                            Button("Import") {
                                Task {
                                    let importedSet = await setVM.importSet(withCode: importCode)
                                    if importedSet != nil {
                                        authVM.addNewSet(newSet: importedSet!)
                                        showingImportSheet = false
                                        alertMessage = "Set imported successfully!"
                                    } else {
                                        alertMessage = setVM.errorMessage ?? "Failed to import set"
                                    }
                                    showingAlert = true
                                }
                            }
                            .disabled(importCode.isEmpty)
                        }
                    }
                    .navigationTitle("Import Set")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button("Cancel") {
                            showingImportSheet = false
                        }
                    }
                }
                .presentationDetents([.height(250)])
            }
        }
        .alert("Explore", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await setVM.fetchPublicSets()
        }
    }
    
    private func download(set: FlashcardSet) {
        let newSet = setVM.makePersonalCopy(from: set)
        authVM.addNewSet(newSet: newSet)
        alertMessage = "Set downloaded to your library."
        showingAlert = true
    }
}

#Preview {
    ExploreView()
}
