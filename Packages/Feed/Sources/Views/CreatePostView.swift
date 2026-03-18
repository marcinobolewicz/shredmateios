import SwiftUI
import Networking

struct CreatePostView: View {

    @State private var viewModel: CreatePostViewModel

    init(feedService: any FeedServiceProtocol, onSuccess: @escaping () -> Void) {
        _viewModel = State(
            initialValue: CreatePostViewModel(feedService: feedService, onSuccess: onSuccess)
        )
    }

    var body: some View {
        Form {
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
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text(FeedStrings.ok.localized)) {
                    viewModel.dismissError()
                }
            )
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }
}
