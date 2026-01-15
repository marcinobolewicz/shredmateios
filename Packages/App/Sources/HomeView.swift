import SwiftUI
import Auth
import Core

/// Home view for authenticated users
public struct HomeView: View {
    
    private let authState: AuthState
    private let riderService: any RiderServiceProtocol
    
    public init(authState: AuthState, riderService: any RiderServiceProtocol) {
        self.authState = authState
        self.riderService = riderService
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                welcomeSection
                userInfoSection
                
                // Temporary Profile button
                NavigationLink {
                    ProfileView(
                        viewModel: ProfileViewModel(
                            riderService: riderService,
                            authState: authState
                        )
                    )
                } label: {
                    Label("Profile", systemImage: "person.circle")
                }
                .buttonStyle(.borderedProminent)
                
                logoutButton
            }
            .padding()
            .navigationTitle("Home")
        }
    }
    
    // MARK: - Sections
    
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Image("shredmate-logo", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(20)
                .background(
                    Circle()
                        .fill(.black)
                )
            
            Text("Welcome to ShredMate!")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    
    private var userInfoSection: some View {
        VStack(spacing: 8) {
            if let user = authState.user {
                Text(user.name ?? user.email)
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let rider = authState.rider, let type = rider.type {
                Text(type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var logoutButton: some View {
        Button {
            Task { await authState.logout() }
        } label: {
            if authState.isLoading {
                ProgressView()
            } else {
                Text("Sign Out")
            }
        }
        .buttonStyle(.bordered)
        .disabled(authState.isLoading)
        .padding(.top, 20)
    }
}

