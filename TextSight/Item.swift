//
//  Item.swift
//  TextSight
//
//  Created by Kavindu Dissanayake on 2023-10-29.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
