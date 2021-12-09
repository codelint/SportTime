//
//  BootstrapView.swift
//  going
//
//  Created by gzhang on 2021/5/19.
//

import Foundation
import SwiftUI
import AdSupport
import AppTrackingTransparency

struct BootstrapView<Target:View>: View {
    
    @State var isTargetPresent = false
    @State var text = "loadding..."
    
    var target: () -> Target
    
    var body: some View {
        if isTargetPresent {
            target()
        }else{
            Text(text).onAppear() {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            // Authorized
                            self.text = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        // self.label.text = idfa.uuidString
                        case .denied,
                             .notDetermined,
                             .restricted:
                            text = "loading..."
                            break
                        @unknown default:
                            break
                        }
                        
                    }
                }
                
                isTargetPresent = true
            }
        }
    }
}
