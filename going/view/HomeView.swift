//
//  HomeView.swift
//  going
//
//  Created by gzhang on 2021/4/4.
//

import Foundation
import SwiftUI

struct HomeView : View {
    var body: some View {
        if UIDevice.current.name.lowercased().contains("pad") {
            NavigationView {
                VStack{}
                ActionView()
            }
            
        }else{
            NavigationView {
                ActionView()
            }
        }
    }
}


#if DEBUG
struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HomeView()
        
    }
}
#endif
