import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var setVM: SetSharingViewModel
    @State private var showingImportSheet = false
    @State private var importCode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if setVM.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(setVM.publicSets) { set in
                            SetCardView(set: set)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Explore Sets")
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
        .alert("Import Set", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await setVM.fetchPublicSets()
        }
    }
}

#Preview {
    ExploreView()
}
