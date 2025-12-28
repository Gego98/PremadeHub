import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if viewModel.conversations.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.cyan)
                        
                        Text("No Messages")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Connect with players and start chatting")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            // Navigate to search tab
                        }) {
                            Text("Find Players")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.cyan)
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                    }
                } else {
                    // Conversations List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.conversations) { conversation in
                                ConversationRowView(conversation: conversation)
                                
                                if conversation.id != viewModel.conversations.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.leading, 70)
                                }
                            }
                        }
                    }
                }
        }
        .onAppear {
            viewModel.loadConversations()
        }
    }
}

struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        Button(action: {
            // Navigate to chat view
        }) {
            HStack(spacing: 15) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.3))
                        .frame(width: 55, height: 55)
                    
                    Text(String(conversation.otherUser.summonerName.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                // Message Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(conversation.otherUser.summonerName)#\(conversation.otherUser.summonerTag)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(conversation.lastMessageTime, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(conversation.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if conversation.unreadCount > 0 {
                            Text("\(conversation.unreadCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Color.cyan)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MessagesView()
}
