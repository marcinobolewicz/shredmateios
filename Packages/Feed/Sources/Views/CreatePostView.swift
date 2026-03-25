import SwiftUI
import MediaPicker
import Networking
import Places

struct CreatePostView: View {

    @State private var viewModel: CreatePostViewModel
    @State private var isPlacePickerPresented = false
    @State private var isPhotoCropPickerPresented = false

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
            photoSection
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
        .sheet(isPresented: $isPlacePickerPresented) {
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
        .imageCropPicker(isPresented: $isPhotoCropPickerPresented) { result in
            if case .success(let data) = result {
                viewModel.photoSelected(data)
            }
        }
        .interactiveDismissDisabled(viewModel.isSubmitting || viewModel.isUploadingPhoto)
    }

    // MARK: - Sections

    private var placeSection: some View {
        Section {
            Button {
                isPlacePickerPresented = true
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

    @ViewBuilder
    private var photoSection: some View {
        Section(FeedStrings.photoLabel.localized) {
            if let photoData = viewModel.selectedPhotoData,
               let uiImage = UIImage(data: photoData) {
                photoPreview(uiImage)
            } else {
                Button {
                    isPhotoCropPickerPresented = true
                } label: {
                    Label(FeedStrings.addPhoto.localized, systemImage: "photo")
                }
            }
        }
    }

    private func photoPreview(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack {
                if viewModel.isUploadingPhoto {
                    ProgressView()
                        .controlSize(.small)
                    Text(FeedStrings.uploadingPhoto.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Button {
                        isPhotoCropPickerPresented = true
                    } label: {
                        Text(FeedStrings.changePhoto.localized)
                            .font(.subheadline)
                    }
                }

                Spacer()

                Button(FeedStrings.removePhoto.localized, role: .destructive) {
                    isPhotoCropPickerPresented = false
                    viewModel.removePhoto()
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
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
