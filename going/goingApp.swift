//
//  goingApp.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import SwiftUI

@main
struct goingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ActionView()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
