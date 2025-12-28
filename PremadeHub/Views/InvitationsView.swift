import SwiftUI

struct InvitationsView: View {
    @StateObject private var viewModel = InvitationsViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if viewModel.invitations.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "envelope.open")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Invitations")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Connect with players to receive team invitations")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.invitations) { invitation in
                            InvitationCardView(
                                invitation: invitation,
                                onAccept: {
                                    viewModel.acceptInvitation(invitation)
                                },
                                onReject: {
                                    viewModel.rejectInvitation(invitation.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.loadInvitations()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

struct InvitationCardView: View {
    let invitation: TeamInvitation
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: invitation.teamType == .duo ? "person.2.fill" : "person.3.fill")
                    .foregroundColor(.cyan)
                
                Text(invitation.teamType == .duo ? "Duo Invitation" : "Clash Team Invitation")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(timeAgoString(from: invitation.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // From User
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(String(invitation.fromUserName.prefix(1)).uppercased())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.inviterDisplayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("wants to team up with you!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                Button(action: onReject) {
                    Text("Decline")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: onAccept) {
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

#Preview {
    InvitationsView()
}
