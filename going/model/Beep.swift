//
//  Beep.swift
//  going
//
//  Created by gzhang on 2021/3/25.
//

import Foundation
import SwiftyJSON

class Beep: Identifiable{
    
    var uuid: String = UUID().description
    var text = ""
    var time = 1
    var timeBeep = true
    
    var times: Int = 1
    
    var id: String {
        return uuid
    }
    
    init(text: String = "", time: Int = 1, timeBeep: Bool = true, uuid: String = UUID().description){
        self.text = text
        self.time = time
        self.timeBeep = timeBeep
        self.uuid = uuid
    }
    
    init(description: String){
        let json = JSON(parseJSON: description)
        
        uuid = json["uuid"].string ?? uuid
        text = json["text"].string ?? text
        time = json["time"].int ?? time
        times = json["times"].int ?? times
        timeBeep = json["timeBeep"].bool ?? timeBeep
        
    }
    
    var description: String {
        return "{\"uuid\":\"\(uuid)\",\"text\":\"\(text)\",\"time\":\(time), \"timeBeep\":\(timeBeep), \"times\":\(times)}"
    }
    
    static let empty = Beep()
}
