import SwiftUI
import Networking
import Places

struct CreatePostView: View {

    @State private var viewModel: CreatePostViewModel
    @State private var isPickerPresented = false

    let placesService: any PlacesServiceProtocol

    init(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        onSuccess: @escaping () -> Void
    ) {
        self.placesService = placesService
        _viewModel = State(
            initialValue: CreatePostViewModel(feedService: feedService, onSuccess: onSuccess)
        )
    }

    var body: some View {
        Form {
            placeSection
            captionSection
        }
        .navigationTitle(FeedStrings.createPostTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Group {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Button(FeedStrings.postButton.localized) {
                            viewModel.submit()
                        }
                        .fontWeight(.semibold)
                        .disabled(!viewModel.canSubmit)
                    }
                }
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            NavigationStack {
                PlacePickerView(
                    placesService: placesService,
                    selection: $viewModel.selectedPlace
                )
            }
        }
        .alert(item: $viewModel.error) { err in
            Alert(
                title: Text(err.title),
                message: Text(err.message),
                dismissButton: .default(Text(FeedStrings.ok.localized)) {
                    viewModel.dismissError()
                }
            )
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    // MARK: - Sections

    private var placeSection: some View {
        Section {
            Button {
                isPickerPresented = true
            } label: {
                HStack {
                    Text(FeedStrings.placeLabel.localized)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(viewModel.selectedPlace?.name ?? FeedStrings.placePlaceholder.localized)
                        .foregroundStyle(viewModel.selectedPlace == nil ? .secondary : .primary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private var captionSection: some View {
        Section {
            TextField(
                FeedStrings.captionPlaceholder.localized,
                text: $viewModel.caption,
                axis: .vertical
            )
            .lineLimit(3...8)
        } footer: {
            HStack {
                Spacer()
                Text("\(viewModel.captionCount)/\(viewModel.captionLimit)")
                    .font(.caption)
                    .foregroundStyle(viewModel.isOverLimit ? .red : .secondary)
                    .animation(.easeInOut, value: viewModel.isOverLimit)
            }
        }
    }
}
