//
//  WelcomeView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI

struct WelcomeView: View {
    
    @Binding var email: String
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Joke Generator!")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.all, 32)
                
                Image("jokerTheme")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.size.width, height: 240)
                    .scaledToFit()
                    .ignoresSafeArea()
                    .padding()
                
                Spacer()
                
                NavigationLink {
                    LoginView(mailLoggedIn: $email)
                } label: {
                    Text("Login")
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                NavigationLink {
                    SignupView(mailLoggedIn: $email)
                } label: {
                    Text("Create an account")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                        .padding()
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .background(.black)
        }
    }
}

#Preview {
    WelcomeView(email: .constant(""))
}
