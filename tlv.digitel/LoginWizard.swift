//
//  LoginWizard.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 10/08/2022.
//

import SwiftUI

struct LoginWizard: View {

    @StateObject private var signinVM = SignInViewModel()
    @EnvironmentObject var authentication: Authentication

    var body: some View {
        Group {
            switch authentication.state {
                
                case .initial:
                    CredentialsView(signinVM: signinVM)
                        .environmentObject(authentication)
                
                case .initialized:
                    OTPView(signinVM: signinVM)
                        .environmentObject(authentication)
                
                default:
                    Text("No action")
            }
        }
    }
}

struct LoginWizard_Previews: PreviewProvider {
    static var previews: some View {
        LoginWizard()
    }
}
