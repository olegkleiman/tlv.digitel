//
//  OTPView.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 10/08/2022.
//

import SwiftUI
import Alamofire
import KeychainSwift

struct OTPView: View {
    
    @EnvironmentObject var authentication: Authentication
    
    @ObservedObject var signinVM: SignInViewModel
    
    @State private var otp: String = ""
    @State private var isLoading: Bool = false
    @State private var didError: Bool = false
    @State private var errorMessage: String = ""
    @State var jsonTokens: DecodableTokens?
    
    var body: some View {
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Label {
                        ZStack(alignment: .leading) {
                            if( otp.isEmpty ) {
                                Text("Code you've received")
                                    .foregroundColor(.gray)
                            }
                            TextField("", text: $otp)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    } icon: {
                        Image(systemName: "message")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))

                }
                .padding()

                if( self.isLoading ) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    Button("Continue") {
                        
                        self.isLoading.toggle()
                        defer { self.isLoading.toggle() }

                        signinVM.login(clientId: CLIENT_ID, otp: otp) { (tokens, error) in

                            guard tokens != nil
                            else {
                                self.didError.toggle()
                                print("🥶 \(String(describing: error?.localizedDescription))")
                                self.errorMessage = error!.localizedDescription
                                
                                return
                            }
                            
                            self.jsonTokens = tokens

                            let jsonEncoder = JSONEncoder()
                            let jsonData = try jsonEncoder.encode(tokens)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

                            let keychain = KeychainSwift()
                            let appID = "GX7N6F8DFJ.gov.tel-aviv.digitel"
                            keychain.accessGroup = appID
                            let _ = keychain.set(jsonString!, forKey: "tlv_tokens")

                            let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
                            keychain.accessGroup = keychainAccessGroupName
                            let _ = keychain.set(jsonTokens!.sso_token!, forKey: "sso_token")

                            authentication.state = .authenticated
                        }
                    }
                    .padding()
                    .alert("Error",
                           isPresented: $didError,
                           actions: {
                        
                                Button("Retry", role: nil, action: {} )
                                Button("Cancel", role: .cancel, action: {} )
                            },
                           message: {
                                Text(errorMessage)
                            }
                           )
                }
            }
        }

    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView(signinVM: SignInViewModel())
    }
}
