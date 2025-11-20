import SwiftUI

struct PublicSetDetailView: View {
    let set: FlashcardSet
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var setVM: SetSharingViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isDownloading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(set.title)
                        .font(.title.bold())

                    HStack(spacing: 12) {
                        Label("\(set.cardCount) cards", systemImage: "square.on.square")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(set.updatedAt, style: .relative)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(set.color.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )

                Button {
                    downloadSet()
                } label: {
                    HStack {
                        if isDownloading {
                            ProgressView()
                                .tint(.white)
                        }
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download to My Sets")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(set.color)
                .disabled(isDownloading)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Cards")
                        .font(.headline)

                    if set.cards.isEmpty {
                        Text("This set is empty.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(set.cards) { card in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(card.question)
                                    .font(.subheadline.weight(.semibold))
                                Text(card.answer)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .padding()
        }
        .navigationTitle("Public Set")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Download", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func downloadSet() {
        guard !isDownloading else { return }
        isDownloading = true

        let newSet = setVM.makePersonalCopy(from: set)
        authVM.addNewSet(newSet: newSet)

        alertMessage = "Set downloaded to your library."
        showingAlert = true
        isDownloading = false
    }
}

#Preview {
    PublicSetDetailView(set: SampleData.sets[0])
        .environmentObject(AuthViewModel())
        .environmentObject(SetSharingViewModel())
}
