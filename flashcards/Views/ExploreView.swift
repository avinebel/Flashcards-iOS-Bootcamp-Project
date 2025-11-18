import SwiftUI

struct ExploreView: View {
    @StateObject private var sharingVM = SetSharingViewModel()
    @State private var showingImportSheet = false
    @State private var importCode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if sharingVM.isLoading {
                    ProgressView()
                } else {
                    List(sharingVM.publicSets) { set in
                        SetCardView(set: set)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Explore Sets")
            .toolbar {
                Button {
                    showingImportSheet = true
                } label: {
                    Label("Import Set", systemImage: "square.and.arrow.down")
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
                                    let success = await sharingVM.importSet(withCode: importCode)
                                    if success {
                                        showingImportSheet = false
                                        alertMessage = "Set imported successfully!"
                                    } else {
                                        alertMessage = sharingVM.errorMessage ?? "Failed to import set"
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
            await sharingVM.fetchPublicSets()
        }
    }
}

#Preview {
    ExploreView()
}
