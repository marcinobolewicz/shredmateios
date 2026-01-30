import SwiftUI

struct PlacesListView: View {
    @Bindable var viewModel: PlacesViewModel
    
    var body: some View {
        List {
            Text("Places list coming soon...")
                .foregroundStyle(.secondary)
        }
        .listStyle(.plain)
    }
}
