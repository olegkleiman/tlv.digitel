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
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
//            Spacer()
            
            HStack {
                Text("Welcome ")
                    .foregroundColor(.white)
                Text(verbatim: name)
                    .foregroundColor(.white)
                    .onAppear {
                        

                        
                        let jwt = try? decode(jwt: accessToken!)

                        let claim = jwt?.claim(name: "name")
                        self.name = claim?.string ?? "unknown"
                    }
            }
            .padding()
            
//            Spacer()
            
            }
        }

}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {

        HomeView(accessToken: .constant("eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlRqSGtSaDFxXzBTWXBJUjZhTmE4ZldUWHBWSW9wNWl3SjhQUmc5YjRrNUEifQ.eyJpc3MiOiJodHRwczovL3RsdmZwYjJjcHByLmIyY2xvZ2luLmNvbS83ODFlYzI0ZC05YWE1LTQ2MjgtOWZjMS01YTFmMTNkYzA0MjQvdjIuMC8iLCJleHAiOjE2NTc1ODMzOTcsIm5iZiI6MTY1NzU3OTc5NiwiYXVkIjoiODczOWM3ZjEtZTgxMi00NDYxLWI5YzgtZDY3MDMwN2RkMjJiIiwic3ViIjoiYTBkYzQ5YmEtZDI5Ny00M2E1LTkzYWQtZjM1MTJlMjQ4MTdiIiwic2lnbkluTmFtZXMucGhvbmVOdW1iZXIiOiIwNTQzMzA3MDI2Iiwic2lnbkluTmFtZXMuY2l0aXplbklkIjoiMzEzMDY5NDg2IiwidXBuIjoiYTBkYzQ5YmEtZDI5Ny00M2E1LTkzYWQtZjM1MTJlMjQ4MTdiQFRsdmZwQjJDUFBSLm9ubWljcm9zb2Z0LmNvbSIsIm5hbWUiOiJPbGVnIEtsZWltYW4iLCJzaWduSW5OYW1lc0luZm8uZW1haWxBZGRyZXNzIjoib2xlZ19rbGV5bWFuQHlhaG9vLmNvbSIsImZhbWlseV9uYW1lIjoiS2xlaW1hbiIsImdyb3VwcyI6IltEaWdpdGVsIE1lbWJlcnNdIiwic2NwIjoiVExWLkRpZ2l0ZWwuQWxsIiwiYXpwIjoiODczOWM3ZjEtZTgxMi00NDYxLWI5YzgtZDY3MDMwN2RkMjJiIiwidmVyIjoiMS4wIiwiaWF0IjoxNjU3NTc5Nzk2fQ.xPN_j4nT2RRPedAOsvyLkty-K-zl96BVedE6ORNZl6X136WhKOjfZTdDV5ICYMAw_p2nfX2XOm8BI4e6VTfCK7gH84u2s6tlu4T_zCOf-so9OkWXd-bYpHSM-m1pJ_gzCo04sXYNWn8AWXUzZE_UFiH29YacXQUH6tR-kyqnIfpqOes-yALwRWczbN-x1j4E_GLhY90H--KNVxdnpZCkaGkbUgst921PlTEmUZuszD_hQMgI4cbVk0rvncJmdMAJ80P_2ZVzEFWc05pKkJXSlHSFAronSm6RZb4KBAW4DKEScaAHSTAckS4qCRCHHrJ1Sf9lVeQXJ_mPTabALsJ6uQ"))
    }
}
