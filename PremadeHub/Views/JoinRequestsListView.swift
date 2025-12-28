import SwiftUI

struct JoinRequestsListView: View {
    let teamId: String
    let onMemberAdded: () -> Void  // Callback to refresh team
    @StateObject private var viewModel = JoinRequestsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if viewModel.requests.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Pending Requests")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("When players request to join, they'll appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.requests) { request in
                            JoinRequestCard(
                                request: request,
                                onAccept: {
                                    acceptRequest(request)
                                },
                                onReject: {
                                    rejectRequest(request.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Join Requests")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadRequests(teamId: teamId)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    private func acceptRequest(_ request: JoinRequest) {
        Task {
            do {
                try await viewModel.acceptRequest(request)
                onMemberAdded() // Refresh parent view
            } catch {
                viewModel.errorMessage = "Failed to accept request"
                viewModel.showError = true
            }
        }
    }
    
    private func rejectRequest(_ requestId: String) {
        Task {
            do {
                try await viewModel.rejectRequest(requestId)
            } catch {
                viewModel.errorMessage = "Failed to reject request"
                viewModel.showError = true
            }
        }
    }
}

struct JoinRequestCard: View {
    let request: JoinRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    @State private var isProcessing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: request.teamType == .duo ? "person.2.fill" : "person.3.fill")
                    .foregroundColor(.cyan)
                
                Text("Join Request")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(timeAgoString(from: request.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Player Info
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(String(request.userName.prefix(1)).uppercased())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.userDisplayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Label(request.userRank, systemImage: "trophy.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Label(request.userRole, systemImage: "gamecontroller.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            
            // Action Buttons
            if !isProcessing {
                HStack(spacing: 10) {
                    Button(action: {
                        isProcessing = true
                        onReject()
                    }) {
                        Text("Reject")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isProcessing = true
                        onAccept()
                    }) {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.cyan)
                            .cornerRadius(10)
                    }
                }
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    Spacer()
                }
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(seconds / 86400)
            return "\(days)d ago"
        }
    }
}
