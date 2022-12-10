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
    let expires_in: Int
    let refresh_token: String
    let id_token: String
}

struct DecodableTokens: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String
    let id_token: String
    let sso_token: String?
    
    init(access_token: String,
         token_type: String,
         expires_in: Int,
         refresh_token: String,
         id_token: String,
         sso_token: String) {
        self.access_token = access_token
        self.token_type = token_type
        self.expires_in = expires_in
        self.refresh_token = refresh_token
        self.id_token = id_token
        self.sso_token = sso_token
    }
    
    init(copyFrom: DecodableRefreshTokens) {
        self.access_token = copyFrom.access_token!
        self.token_type = copyFrom.token_type
        self.expires_in = copyFrom.expires_in
        self.refresh_token = copyFrom.refresh_token
        self.id_token = copyFrom.id_token
        self.sso_token = ""
    }
}

struct MagicLinkResponse: Codable {
    let UTz: String
    let Link: String
    let IsError: Bool?
    let ErrorMessage: String?
}

let DEV_CLIENT_ID: String = "fccb7f50-ba2c-4941-acc3-a2169aab5f50"
let PREPROD_CLIENT_ID: String = "bc00c1e4-30e4-443c-a559-a5b39ff42586"
let PROD_CLIENT_ID: String = "29e60c77-9a0b-4a80-9745-64ba51ff3aa2"

let DEV_TENANT_NAME: String = "tlvfpdev"
let PREPROD_TENANT_NAME: String = "tlvfpb2cppr"
let PROD_TENANT_NAME: String = "b2ctam"

var CLIENT_ID: String = PROD_CLIENT_ID
var TENANT_NAME = PROD_TENANT_NAME

struct HomeView: View {
    
    @EnvironmentObject var authentication: Authentication
    
    @State var name: String = ""
    @State var oauthTokens: DecodableTokens?
    @State var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    @Environment(\.openURL) var openURL
    
    func refreshTokens() {
        
    }
    
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

                            //   SSO token found. Exchange it for OAuth2 tokens
                            let url = "https://api.tel-aviv.gov.il/sso/sso_login?code=W0oWhTIOI-uRnkXlpAgy0fiAXqf9Fit7Oa9ADqoW2isEAzFu7jyt6Q=="
                            let deviceId = UIDevice.current.identifierForVendor!.uuidString
                            struct SSOLoginparams: Encodable
                            {
                                let clientId: String
                                let scope: String
                                let deviceId: String
                                let ssoToken: String
                            }
                            let parameters = SSOLoginparams(clientId: CLIENT_ID,
                                                            scope: "openid offline_access https://\(TENANT_NAME).onmicrosoft.com/digitel/all",
                                                            deviceId: deviceId,
                                                            ssoToken: ssoToken)

                            self.isLoading.toggle()

                            AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                                .validate(statusCode: 200..<500)
//                                .responseJSON(completionHandler: { (response) in
                                .responseDecodable(of: StrictDecodableTokens.self) { response in

                                    self.isLoading.toggle()

                                    switch response.result {

                                        case .success(let jsonTokens):
                                           do {
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
                                        catch let error {
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
                    
                    Button("Launch Site") {
                        let url = "https://api.tel-aviv.gov.il/sso/magic_link?clientId=\(CLIENT_ID)"
                        
                        guard let idToken: String = self.oauthTokens?.id_token
                        else {
                            return
                        }
                        let headers: HTTPHeaders = [
                            .authorization(bearerToken: idToken)
                        ]
                        let interceptor: APIRequestInterceptor = APIRequestInterceptor.shared
                        AF.request(url, method: .get, headers: headers,
                                   interceptor: interceptor)
                            // validate() produces an error that will trigger an automatic retry (via interceptor)
                            .validate(statusCode: 200..<300)
                            .validate(contentType: ["application/json"])
//                                .responseJSON(completionHandler: { (response) in
                            .responseDecodable(of: MagicLinkResponse.self) { response in

                                switch response.result {
                                    case .success(let magicLinkResponse): do {
                                        guard magicLinkResponse.IsError != nil
                                        else {
                                            openURL(URL(string: magicLinkResponse.Link)!)
                                            return
                                        }
                                        
                                    }
                                    case .failure(let error):
                                        print("🥶 \(error)")
                                }

                        }

                    }
                    .padding()
                    
                    Button("Call API (Bruegel)") {
                        let url = "https://api.tel-aviv.gov.il/breugel/hunters"
                        
                        guard let accessToken: String = self.oauthTokens?.access_token
                        else {
                            return
                        }
                            
                        let headers: HTTPHeaders = [
                            .authorization(bearerToken: accessToken)
                        ]
                        
                        AF.request(url,
                                   method: .get,
                                   headers: headers)
                            .validate()
                            .response { response in
                                
                                switch response.result {
                                    case .success(let data):
                                        let string = String(data: data!, encoding: .utf8)!
                                        debugPrint(string)
                                    
                                        self.alertMessage = "Token was accepted"
                                        self.showAlert.toggle()
                                        
                                    case .failure(let error):
                                        debugPrint(error)
                                        if let data = response.data {
                                            let message = String(data: data, encoding: String.Encoding.utf8)
                                            self.alertMessage = message!
                                        }
                                        else {
                                            self.alertMessage = error.localizedDescription
                                            return
                                        }
                                        self.showAlert.toggle()

                                }
                            }
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("For Your Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))

                    }
                }
            }
//            Spacer()

        }
        

    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
            .environmentObject(Authentication())
    }
}

