//
//  SignupView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI

struct SignupView: View {
    @Binding var mailLoggedIn: String
    
    @FocusState var showKeyboard: Bool
    @State private var showAlert: Bool = false
    @State private var alertErr: String = ""
    
    @State var email: String = ""
    @State var password: String = ""
    @State var username: String = ""
    
    var body: some View {
        VStack {
            Text("Signup view")
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
            
            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .modifier(TxtFieldModifier())
                
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .modifier(TxtFieldModifier())
                
                TextField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .modifier(TxtFieldModifier())
            }
            .focused($showKeyboard)
            .submitLabel(.continue)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Dismiss") {
                        showKeyboard = false
                    }
                }
            }
            
            Divider()
                .foregroundStyle(.white)
                .padding()
            
            //signup Btn
            Button {
                Task {
                    try await createUser()
                    
                }
            } label: {
                Text("Create an account")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(isValid() ? .pink : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid())
            
            Spacer()
        }
        .navigationTitle("")
        .background(.black)
        .alert("Error Creating account!", isPresented: $showAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(alertErr)
        }
    }
    
//MARK: - Function
    
    private func isValid() -> Bool {
        return !username.isEmpty && !password.isEmpty && !email.isEmpty
    }
    
    private func createUser() async throws {
        do {
            let user = User(username: username, email: email)
            try await AuthService.shared.createUser(user: user, pw: password)
            UserDefaults.standard.set(email, forKey: USER_EMAIL)
            mailLoggedIn = email
        } catch {
            alertErr = error.localizedDescription
            showAlert.toggle()
        }
        
    }
    
}

#Preview {
    SignupView(mailLoggedIn: .constant(""))
}
