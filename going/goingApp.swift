//
//  goingApp.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import SwiftUI
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var isForceLandscape:Bool = false
    var isForcePortrait:Bool = false
    var isForceAllDerictions:Bool = false //支持所有方向
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback)
            // AVAudioSession.sharedInstance().setActive(true, error: nil)
        }catch _ {
            
        }
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if isForceAllDerictions == true {
            return .all
        } else if isForceLandscape == true {
            return .landscape
        } else if isForcePortrait == true {
            return .portrait
        }
        return .portrait
    }
    
    func applicationDidEnterBackground(_ application: UIApplication){
        print("applicationDidEnterBackground")
    }
    
    func applicationWillResignActive(_ application: UIApplication){
        print("applicationWillResignActive")
    }
    
}

@main
struct goingApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            BootstrapView {
                HomeView()
            }
            
            // BeepSheet()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
//    override func supportedInterfaceOrientations() -> Int {
//        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
//    }
    

}
