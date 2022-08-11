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
    var clientId: String
    
    @State private var otp: String = ""
    @State private var isLoading: Bool = false
    
    @State var jsonTokens: DecodableTokens?
    
    var body: some View {
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("OTP")
                        .textContentType(.oneTimeCode)
                        .foregroundColor(.white)
                        .padding()
                        .font(.body)
                    TextField("Code you've received", text: $otp)
//                        .foregroundColor(.white)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                        .keyboardType(.numberPad)
                }
                .padding()

                if( self.isLoading ) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    Button("Continue") {
                        let url = URL(string: "https://tlvsso.azurewebsites.net/api/login")!
                        
                        let deviceId = UIDevice.current.identifierForVendor!.uuidString
                        let parameters: [String: String] = [
                            "phoneNumber": signinVM.credentials.phoneNumber,
                            "otp": otp,
                            "clientId": clientId,
                            "scope": "openid offline_access https://TlvfpB2CPPR.onmicrosoft.com/\(clientId)/TLV.Digitel.All",
                            "deviceId": deviceId
                        ]
                        
                        self.isLoading.toggle()
                        
                        AF.request(url,
                                   method: .post,
                                   parameters: parameters,
                                   encoder: JSONParameterEncoder.default)
                        .validate(statusCode: 200..<300)
                        .responseDecodable(of: DecodableTokens.self) { response in
                            
                            switch response.result {
                                case .success(let tokens):
                                    do {
                                        defer { self.isLoading.toggle() }
                                        
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
                                        
                                    } catch  let error {
                                        print("🥶 \(error)")
                                    }
                                
                                case .failure(let error):
                                    print("🥶 \(error)")
                            }
                            
                        }
                    }
                    .padding()

                }
            }
        }

    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView(signinVM: SignInViewModel(),
                clientId: "8739c7f1-e812-4461-b9c8-d670307dd22b")
    }
}
