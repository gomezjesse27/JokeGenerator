//
//  SignupView.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/6/24.
//

import SwiftUI

struct SignupView: View {
    
    @FocusState var showKeyboard: Bool
    @State private var showAlert: Bool = false
    
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
                
            } label: {
                Text("Create an account")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
        }
        .navigationTitle("")
        .background(.black)
        .alert("Error Creating account!", isPresented: $showAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("There is something wrong with your signup preocess, please try again.")
        }
    }
    
//MARK: - Function
    
    private func createUser() async throws {
        try await AuthService.shared.createUser(user: User(username: username, email: email)) { show, error in
            self.showAlert = show
        }
        
    }
    
}

#Preview {
    SignupView()
}
