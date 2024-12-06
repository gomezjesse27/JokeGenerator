//
//  WelcomeView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI

struct WelcomeView: View {
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Joke Generator!")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .padding()
                
                Spacer()
                
                NavigationLink {
                    LoginView()
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
                    SignupView()
                } label: {
                    Text("Create an account")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                        .padding()
                }
            }
            .navigationTitle("Welcome!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WelcomeView()
}
