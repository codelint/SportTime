//
//  BeepSession.swift
//  going
//
//  Created by gzhang on 2021/3/25.
//

import Foundation
import CoreData
import SwiftyJSON

extension BeepSession {
    
    var beeps: [Beep] {
        get {
            var results = [Beep]()
            if let arr_str = self.beep_array {
                if let arr = JSON(arr_str).array {
                    for item in arr {
                        if let text = item["text"].string, let time = item["time"].int, let timeBeep = item["timeBeep"].bool, let uuid = item["uuid"].string {
                            
                            results.append(Beep(text: text, time: time, timeBeep: timeBeep, uuid: uuid))
                            
                        }
                    }
                }
            }
            
            return results
        }
        
        set {
            self.beep_array = "[\(newValue.map({ $0.description }).joined(separator: ","))]"
        }
    }
    
    var iterval_beep: Beep? {
        get {
            return self.interval_info == nil ? nil : Beep(description: self.interval_info!)
        }
        set {
            self.interval_info = newValue == nil ? nil : newValue!.description
        }
        
    }
    
    var repeats: Int {
        get {
            return Int(self.times)
        }
        set {
            self.times = Int64(newValue)
        }
        
    }
}

