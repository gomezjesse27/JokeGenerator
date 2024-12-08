//
//  SettingView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI

struct SettingView: View {
    
    @State var username: String = "Group 4"
    
    @Binding var showSetting: Bool
    @Binding var emailLoggedIn: String
    @Binding var user: User
    
//MARK: - View
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Username: \(user.username)")
                    .padding()
                
                Text("Email: \(user.email)")
                    .padding()
                
                Spacer()
                
                Button(action: signOut) {
                    Text("Sign out")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
            }
            .navigationTitle("Setting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSetting.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                    }
                    
                }
            }
        }
    }
    
//MARK: - Function
    
    private func signOut() {
        AuthService.shared.signOut()
        emailLoggedIn = ""
    }
    
}

#Preview {
    SettingView(showSetting: .constant(true), emailLoggedIn: .constant("mail"), user: .constant(User.exampleUser))
}
