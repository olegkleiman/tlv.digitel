//
//  HomeView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import SwiftUI
import JWTDecode

struct HomeView: View {
    
    @Binding var accessToken: String?
    
    @State var name: String = ""
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Welcome ")
                Text(verbatim: name)
                    .onAppear {
                        let jwt = try? decode(jwt: accessToken!)

                        let claim = jwt?.claim(name: "name")
                        self.name = claim?.string ?? "unknown"
                    }
            }
            .padding()
            
            Spacer()
            
            }
        }

}

//struct HomeView_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        HomeView()
//    }
//}
