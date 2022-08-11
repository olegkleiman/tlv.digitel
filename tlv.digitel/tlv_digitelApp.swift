//
//  tlv_digitelApp.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import SwiftUI

@main
struct tlv_digitelApp: App {

    @State var deeplinkTarget: DeeplinkManager.DeeplinkTarget?
    @State var accessToken: String?
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
            
//            Group {
//
//                switch self.deeplinkTarget {
//                    case .home:
//                        HomeView(accessToken: $accessToken)
//                    case .login:
//                        LoginView()
//                    case .none:
//                        LoginView()
//                }
//
//            }
//            .onOpenURL { url in
//                let deeplinkManager = DeeplinkManager()
//                let deeplink = deeplinkManager.manage(url: url)
//
//                self.accessToken = deeplinkManager.accessToken
//                self.deeplinkTarget = deeplink
//            }
        }
    }
}
