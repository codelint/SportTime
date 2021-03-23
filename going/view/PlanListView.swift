//
//  PlanListView.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import Foundation
import SwiftUI


struct PlanListView: View {
    
    var body: some View {
        VStack {
            LineWrapper(names: ["Plan1", "Plan2", "Plan3adfdsfasdfsadfsadf"]) { (title: String) in
                Button(action: {
                    
                }){
                    ZStack{
                        Circle()
                            .frame(width: (UIScreen.main.bounds.width - 48)/3, height: (UIScreen.main.bounds.width - 48)/3)
                            .foregroundColor(.blue)
                        
                        Text(title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .frame(width: (UIScreen.main.bounds.width - 108)/3, height: (UIScreen.main.bounds.width - 108)/3)
                    }
                }
                
                
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        
    }
    
    
    
}


#if DEBUG
struct PlanListView_Previews: PreviewProvider {
    static var previews: some View {
        PlanListView()
    }
}
#endif
