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

let DEV_CLIENTID: String = "fccb7f50-ba2c-4941-acc3-a2169aab5f50"
let PREPROD_CLIENT_ID: String = "bc00c1e4-30e4-443c-a559-a5b39ff42586"

var CLIENT_ID: String = PREPROD_CLIENT_ID

struct CredentialsView: View {
    
    @ObservedObject var signinVM: SignInViewModel
    
    @EnvironmentObject var authentication: Authentication
    
    //MARK: - PROPERTIES
    @State var isLoading: Bool = false
    @State private var clientId: String = PREPROD_CLIENT_ID
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var dataAvailable = false
    
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
                    
                    HStack {
                        Menu {
                            Button {
                                CLIENT_ID = DEV_CLIENTID
                                clientId = DEV_CLIENTID
                            } label: {
                                Text("Development")
                                if clientId == DEV_CLIENTID {
                                    Image(systemName: "checkmark")
                                }
                            }
                            
                            Button {
                                CLIENT_ID = PREPROD_CLIENT_ID
                                clientId = PREPROD_CLIENT_ID
                            } label: {
                                Text("Pre-Production")
                                if clientId == PREPROD_CLIENT_ID  {
                                    Image(systemName: "checkmark")
                                }
                            }
                        } label: {
                            Text("Environment")
                                .font(.body)
                                .foregroundColor(.white)
                            Image(systemName: "tag.circle")
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    .frame(minWidth: 0, maxHeight: 300, alignment: .topLeading)
                    
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
                                
                                dataAvailable = true
                                
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
