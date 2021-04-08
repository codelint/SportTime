//
//  BeepGlobal.swift
//  going
//
//  Created by gzhang on 2021/4/8.
//

import Foundation
import CoreData
import SwiftyJSON

enum BeepGlobalContentType: String {
    case int, string, double, json, dictionary, array
}

extension BeepGlobal {
    
    var content_type: BeepGlobalContentType {
        get {
            return BeepGlobalContentType(rawValue: self.type ?? "string") ?? BeepGlobalContentType.string
        }
        set {
            self.type = newValue.rawValue
        }
    }
    

    var string: String? {
        get {
            return self.content
        }
        set {
            self.content = newValue
            self.content_type = BeepGlobalContentType.string
        }
    }
    
    var int: Int? {
        get {
            return self.content == nil ? nil : Int(self.content!)
        }
        set {
            self.content = newValue == nil ? nil : "\(newValue!)"
            self.content_type = BeepGlobalContentType.int
        }
    }
    
    var double: Double? {
        get {
            return self.content == nil ? nil : Double(self.content!)
        }
        set {
            self.content = newValue == nil ? nil : "\(newValue!)"
            self.content_type = BeepGlobalContentType.double
        }
    }
    
    var strings: [String] {
        get {
            return (self.content != nil ? JSON(parseJSON: self.content!).array?.map({ $0.string ?? "" }) : nil ) ?? [String]()
        }
        set {
            let str = newValue.map( { "\"\($0)\"" } ).joined(separator: ",")
            self.content = "[\(str)]"
            self.content_type = BeepGlobalContentType.array
        }
    }
    
}
