//
//  TextSightApp.swift
//  TextSight
//
//  Created by Kavindu Dissanayake on 2023-10-29.
//

import SwiftUI
import SwiftData

@main
struct TextSightApp: App {

    var body: some Scene {
        WindowGroup {
            DarkModeWrapper {
                
                BottomTabBar()
            }
        }
      
    }
}
