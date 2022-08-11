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

struct ContentView: View {
    
    @StateObject var authentication = Authentication()
    
    @State private var isLoading = false
    
    var body: some View {

        Group {
            
            switch authentication.state {
                
                case .initial:
                    LoginWizard()
                        .environmentObject(authentication)

                case .initialized:
                    LoginWizard()
                        .environmentObject(authentication)

                case .authenticated:
                    HomeView()
                        .environmentObject(authentication)
                
                default:
                    Text("No View here")
            }
            
        }
        .onAppear() {

            // Only find the appropriate tokens.
            // The actual work with them will be done in HomeView
            
            let keychain = KeychainSwift()
            let appID = "GX7N6F8DFJ.gov.tel-aviv.digitel"
            keychain.accessGroup = appID
            
            if let _ = keychain.get("tlv_tokens") {
                // OAuth2 tokens found. Just use them inside HomeView
                authentication.state = .authenticated
            } else {
                
                let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
                keychain.accessGroup = keychainAccessGroupName
                if let _ = keychain.get("sso_token") {
                    // SSO token found. HomeView will finish the authentication process
                    authentication.state = .authenticated
                } else {
                    // Perform Interactive Login
                    self.authentication.state = .initial
                }
                
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
