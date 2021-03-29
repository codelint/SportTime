//
//  CommonUtil.swift
//  going
//
//  Created by gzhang on 2021/3/22.
//

import Foundation
import SwiftyJSON


class CommonUtil {
    
    enum ImgStyle: String {
        case resize_640, resize_128, resize_256, resize_64, resize_92
    }
    
    func wait(for sec: Int, callback: @escaping () -> Void){
        self.wait(for: Double(sec), callback)
    }
    
    func wait(for sec: Double, _ callback: @escaping () -> Void){
        if sec > 0.001 {
            DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
               callback()
            }
        }else{
            callback()
        }
        
    }
    
    func t(_ src: String) -> String{
        return src
    }
    
    func img2cdn(_ url: String,_ style: ImgStyle = .resize_256) -> String{
        var img_url = url
        img_url = img_url.replacingOccurrences(of: "cbu01.alicdn.com", with: "samulala-sa.oss-me-east-1.aliyuncs.com")
        img_url = img_url.replacingOccurrences(of: "cbu02.alicdn.com", with: "samulala-sa.oss-me-east-1.aliyuncs.com")
        img_url = img_url.replacingOccurrences(of: "cbu03.alicdn.com", with: "samulala-sa.oss-me-east-1.aliyuncs.com")
        img_url = img_url.replacingOccurrences(of: "cbu04.alicdn.com", with: "samulala-sa.oss-me-east-1.aliyuncs.com")
        if img_url.contains("samulala-sa.oss-me-east-1.aliyuncs.com") {
            if img_url.hasSuffix(".jpg") {
                img_url += "-\(style)?x-oss-process=style/interlace_1"
            }
        }else{
            img_url = img_url + (img_url.contains("?") ? "&" : "?") + "x-oss-process=style/interlace_1"
        }
        // print(img_url)
        return img_url
    }
    
    private var config = [String:String]()
    subscript(key: String) -> String? {
        get {
            return config[key]
        }
        set(newValue) {
            // Perform a suitable setting action here.
        }
    }
    subscript(key: String, _default: String) -> String {
        get {
            return config[key] ?? _default
        }
        set(newValue) {
            // Perform a suitable setting action here.
        }
    }
    
}

/**
 *  logger helper
 */
extension CommonUtil {
    enum LogLevel {
        case info,debug,error,warn
    }
    
    static func log(_ content: Any, _ level: LogLevel = .info){
        print("[\(level)] \(content)")
    }
    
    static func i(_ content: Any){
        log(content, .info)
    }
    
    static func d(_ content: Any){
        log(content, .debug)
    }
    
    static func e(_ content: Any){
        log(content, .error)
    }
    
    static func w(_ content: Any){
        log(content, .warn)
    }
}



let helper: CommonUtil = ({
    return CommonUtil()
})()
