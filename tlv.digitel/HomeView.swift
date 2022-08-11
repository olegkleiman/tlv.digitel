//
//  HomeView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import SwiftUI
import Alamofire
import JWTDecode
import KeychainSwift

struct StrictDecodableTokens: Codable {
    let access_token: String
    let token_type: String
    let expires_in: String
    let refresh_token: String
    let id_token: String
}

struct DecodableTokens: Codable {
    let access_token: String
    let token_type: String
    let expires_in: String
    let refresh_token: String
    let id_token: String
    let sso_token: String?
}

struct HomeView: View {
    
    @EnvironmentObject var authentication: Authentication
    
    @State var name: String = ""
    @State var oauthTokens: DecodableTokens?
    @State var isLoading: Bool = false
    
    var clientId: String = "8739c7f1-e812-4461-b9c8-d670307dd22b"
    
    var body: some View {
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            if( self.isLoading ) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            } else {
                VStack {
                    HStack {
                        Text(verbatim: "Welcome, \(name)")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .onAppear() {
                        let keychain = KeychainSwift()
                        let appID = "GX7N6F8DFJ.gov.tel-aviv.digitel"
                        keychain.accessGroup = appID
                        
                        guard let tokens = keychain.get("tlv_tokens")
                        else {
                            
                            let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
                            keychain.accessGroup = keychainAccessGroupName
                            guard let ssoToken = keychain.get("sso_token")
                            else {
                                // Perform Interactive Login
                                self.authentication.state = .initial
                                return
                            }
                            
                            // SSO token found. Convert it to OAuth2 tokens
                            let url = "https://tlvsso.azurewebsites.net/api/sso_login?code=W0oWhTIOI-uRnkXlpAgy0fiAXqf9Fit7Oa9ADqoW2isEAzFu7jyt6Q=="
                            let deviceId = UIDevice.current.identifierForVendor!.uuidString
                            let parameters: [String: String] = [
                                "clientId": clientId,
                                "scope": "openid offline_access https://TlvfpB2CPPR.onmicrosoft.com/\(clientId)/TLV.Digitel.All",
                                "deviceId": deviceId,
                                "ssoToken": ssoToken
                            ]

                            self.isLoading.toggle()
                            
                            AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                                .validate(statusCode: 200..<500)
//                                .responseJSON(completionHandler: { (response) in
                                .responseDecodable(of: StrictDecodableTokens.self) { response in
                                    
                                    self.isLoading.toggle()
                                    
                                    switch response.result {
                                        
                                        case .success(let jsonTokens): do {
                                            self.oauthTokens = DecodableTokens(access_token: jsonTokens.access_token,
                                                                              token_type: jsonTokens.token_type,
                                                                              expires_in: jsonTokens.expires_in,
                                                                              refresh_token: jsonTokens.refresh_token,
                                                                              id_token: jsonTokens.id_token,
                                                                              sso_token: ssoToken)
                                            
                                            let jsonEncoder = JSONEncoder()
                                            let jsonData = try jsonEncoder.encode(jsonTokens)
                                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

                                            let jwt = try? decode(jwt: self.oauthTokens!.id_token)
                                            let claim = jwt?.claim(name: "name")
                                            self.name = claim?.string ?? "unknown"
                                            
                                            keychain.accessGroup = appID
                                            var _ = keychain.set(jsonString!, forKey: "tlv_tokens")
                                        }
                                        catch  let error {
                                            print("🥶 \(error)")
                                        }
                                        
                                        case .failure(let error):
                                            print("🥶 \(error)")
                                    }
                            }
                            
                            return
                        }
                        
                        // OAuth2 tokens found. Just use them
                        let _data = tokens.data(using: .utf8)!
                        do {
                            let jsonDecoder = JSONDecoder()
                            self.oauthTokens = try jsonDecoder.decode(DecodableTokens.self, from: _data)
                            
                            let jwt = try? decode(jwt: self.oauthTokens!.id_token)
                            let claim = jwt?.claim(name: "name")
                            self.name = claim?.string ?? "unknown"
                            
                        } catch let error {
                            print("Tokens deserialization error: \(error)")
                        }
                    }
                    
                    Button("Sign Out") {
                        let keychain = KeychainSwift()
                        
                        let appID = "GX7N6F8DFJ.gov.tel-aviv.digitel"
                        keychain.accessGroup = appID
                        keychain.delete("tlv_tokens")
                        
                        let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
                        keychain.accessGroup = keychainAccessGroupName
                        keychain.delete("sso_token")
                        
                        self.name = ""
                        self.authentication.state = .initial
                    }
                    .padding()
                }
            }
//            Spacer()

        }
        

    }
}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        HomeView()
    }
}
