//
//  Beep.swift
//  going
//
//  Created by gzhang on 2021/3/25.
//

import Foundation
import SwiftyJSON

class Beep {
    var uuid: String = UUID().description
    var text = ""
    var time = 1
    var timeBeep = false
    
    init(text: String = "", time: Int = 1, timeBeep: Bool = false, uuid: String = UUID().description){
        self.text = text
        self.time = time
        self.timeBeep = timeBeep
        self.uuid = uuid
    }
    
    init(description: String){
        let json = JSON(description)
        
        uuid = json["uuid"].string ?? uuid
        text = json["text"].string ?? text
        time = json["time"].int ?? time
        timeBeep = json["timeBeep"].bool ?? timeBeep
        
    }
    
    var description: String {
        return "{\"uuid\":\"\(uuid)\",\"text\":\"\(text)\"},\"time\":\(time), \"timeBeep\":\(timeBeep)}}"
    }
    
    static let empty = Beep()
}
