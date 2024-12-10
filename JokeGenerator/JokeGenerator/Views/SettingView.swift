//
//  SettingView.swift
//  JokeGenerator
//  Created by  Long Nguyen, Mariah Salgado

import SwiftUI

struct SettingView: View {
    
    @State var username: String = "Group 4"
    
    @Binding var showSetting: Bool
    @Binding var emailLoggedIn: String
    @Binding var user: User
    
//MARK: - View
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: isLandscape ? 10 : 20) {
                // Header
                headerView
                
                Spacer()
                
                // User Information
                VStack(spacing: 20) {
                    userInfoView
                }
                .frame(maxWidth: isLandscape ? geometry.size.width * 0.6 : geometry.size.width * 0.9)// White card for user info
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding()
                
                Spacer()
                
                // Sign-Out Button
                signOutButton
                    .frame(width: isLandscape ? geometry.size.width * 0.4 : geometry.size.width * 0.8)
            }
            .padding()
            .background(Color.blue.opacity(0.7)) // Lighter blue background to match HomeView
            .animation(.easeInOut, value: isLandscape)
        }
        .navigationBarHidden(true)// Hide default navigation bar
    }
}

//MARK: - Subviews

extension SettingView {
    
    var headerView: some View {
        // Header with "Settings" title and close button
        HStack {
            Text("Settings")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                showSetting.toggle()// Close the settings view
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
    
    var userInfoView: some View {
        // Display user information (username and email)/
        VStack(spacing: 10) {
            Text("Username: \(user.username)")
                .font(.title3.bold())
                .foregroundColor(.black)
            
            Text("Email: \(user.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    var signOutButton: some View {
        // Button to sign out the user
        Button(action: signOut) {
            Text("Sign Out")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
}

//MARK: - Functions

extension SettingView {
    private func signOut() {
        AuthService.shared.signOut()
        // Function to handle user sign-out
        emailLoggedIn = ""
    }
}

//MARK: - Preview

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(
            showSetting: .constant(true),
            emailLoggedIn: .constant("test@example.com"),
            user: .constant(User.exampleUser)
        )
    }
}
