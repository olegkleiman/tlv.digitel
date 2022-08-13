//
//  LoginView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import Foundation
import SwiftUI
import Alamofire

struct SendOTPResponse: Codable {
    let isError: Bool
    let errorDesc: String
    let errorId: Int
}

struct CredentialsView: View {
    
    @ObservedObject var signinVM: SignInViewModel
    
    @EnvironmentObject var authentication: Authentication
    
    //MARK: - PROPERTIES
    @State var isLoading: Bool = false
    
    @State  var errorMessage: String = ""
    @State  var showError: Bool = false
    
    var body: some View {
        
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Spacer()
            
            VStack() {
                
                //  logo
                Image("logo-6")
                    .resizable()
                    .frame(width: 166.14, height: 26)
                    .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing:0) {
                    Label {
                        ZStack(alignment: .leading) {
                            if signinVM.credentials.userId.isEmpty {
                                Text("Citizen ID")
                                    .foregroundColor(.white)
                            }
                            TextField("", text: $signinVM.credentials.userId)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    } icon: {
                        Image(systemName: "person")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))
                
                    Label {
                        ZStack(alignment: .leading) {
                            if signinVM.credentials.phoneNumber.isEmpty {
                                Text("Phone Number")
                                    .foregroundColor(.white)
                            }
                            TextField("", text: $signinVM.credentials.phoneNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    } icon: {
                        Image(systemName: "phone")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))
                }
                .padding()

                Spacer()
                
                ZStack {
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .padding()
                        .opacity(isLoading ? 1 : 0)
                    
                    Button("Continue") {
                        Task {
                            self.isLoading.toggle()
                            
                            signinVM.requestOTP { success in
                                let state: Authentication.State = success ? .initialized : .error
                                authentication.updateValidation(_state: state)
                            }

                        }
                    }
                    .opacity(!isLoading ? 1 : 0)
                }
            }
        }
        
    }
    
}

struct Credentials_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CredentialsView(signinVM: SignInViewModel())
        }
    }
}
