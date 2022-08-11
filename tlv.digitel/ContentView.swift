//
//  ContentView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import SwiftUI
import Alamofire
import SwiftKeychainWrapper
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

struct ContentView: View {
    
    @State private var jsonTokens: DecodableTokens?
    @State private var clientId: String = "8739c7f1-e812-4461-b9c8-d670307dd22b"
    
    @State private var isLoading = false
    
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                
                let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
                
                let keychain = KeychainSwift()
//                keychain.accessGroup = keychainAccessGroupName
                
                keychain.delete("tlv_tokens")
                
                guard let tokens = keychain.get("tlv_tokens")
                else {
                    
                    guard let ssoToken = keychain.get("sso_token")
                    else {
                        //pageNum = 1 // perform Interactive Login
                        return
                    }
                    
                    // SSO token found. Convert it to OAuth2 tokens
                    let url = "https://tlvsso.azurewebsites.net/api/sso_login"
                    
                    let deviceId = UIDevice.current.identifierForVendor!.uuidString
                    let parameters: [String: String] = [
                        "clientId": clientId,
                        "scope": "openid offline_access https://TlvfpB2CPPR.onmicrosoft.com/\(clientId)/TLV.Digitel.All",
                        "deviceId": deviceId,
                        "ssoToken": ssoToken
                    ]
                    
                    self.isLoading = true
                    
                    AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                        .responseDecodable(of: StrictDecodableTokens.self) { response in
                            
                            switch response.result {
                                case .success(let jsonTokens): do {
                                    
                                    self.jsonTokens = DecodableTokens(access_token: jsonTokens.access_token,
                                                                      token_type: jsonTokens.token_type,
                                                                      expires_in: jsonTokens.expires_in,
                                                                      refresh_token: jsonTokens.refresh_token,
                                                                      id_token: jsonTokens.id_token,
                                                                      sso_token: ssoToken)
                                    
                                    let jsonEncoder = JSONEncoder()
                                    let jsonData = try jsonEncoder.encode(jsonTokens)
                                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                                
                                    var _ = keychain.set(jsonString!, forKey: "tlv_tokens")
                                    self.isLoading.toggle()
//                                    self.pageNum = 3
                                
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

                
                // Old code
                
                guard let jsonTokensString = KeychainWrapper.standard.string(forKey: "tlv_tokens")
                else {
                 
                    guard let ssoToken = KeychainWrapper.standard.string(forKey: "sso_token")
                    else {
//                                pageNum = 1 // perform Interactive Login
                        return
                    }
                    
                    // SSO token found. Convert it to OAuth2 tokens
                    let url = "https://tlvsso.azurewebsites.net/api/sso_login"
                    
                    
                    return
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
