//
//  File.swift
//  going
//
//  Created by gzhang on 2021/3/22.
//

import Foundation
import SwiftUI
import AVFoundation

class TextPlayer {
    
    var player: AVAudioPlayer?
    
    func play(_ t: Int){
        play(String(t))
    }
    
    func play(_ text: String){
        play(text) { _ in
            
        }
    }
    
    func play(_ t: Int, next: ((String) -> Void)?) {
        play(String(t), next: next)
    }
    
    func play(_ text: String, next: ((String) -> Void)?){
        //stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let t = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        if t.count < 1 {
            next?(text)
            return
        }
        
        let fm = FileManager()
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filepath = "\(path)/\(text).mp3"
        
        if !fm.isReadableFile(atPath: filepath) {
            do {
                
                if let sound = NSDataAsset(name: "Sound/\(text)") {
                    //todo
                    try sound.data.write(to: URL(fileURLWithPath: filepath))
                    print("load audio[\(text)] data from asset")
                }
            }catch let err {
                print(err.localizedDescription)
            }
        }else{
            print("load audio[\(text)] data from local")
        }
        
        if !fm.isReadableFile(atPath: filepath) {
            if let url = URL(string: "https://tts.baidu.com/text2audio?cuid=baike&lan=ZH&ctp=1&pdt=301&vol=32&rate=8&per=4&tex=\(t)") {
                let data = NSData(contentsOf: url)
                data?.write(toFile: filepath, atomically: true)
                print("load audio[\(text)] data from web")
            }else{
                print("url invalid")
            }
        }
        
        do {
            if fm.isReadableFile(atPath: filepath) {
                
                player = try AVAudioPlayer(contentsOf:  URL(fileURLWithPath: filepath))
                if let p = player {
                    // print("歌曲长度：\(p.duration)")
                    p.prepareToPlay()
                    p.play()
                    
                    if let f = next {
                        helper.wait(for: p.duration, {
                            f(text)
                        })
                    }
                }
                
            }else{
                if let f = next {
                    f(text)
                }
            }
            
            
            
        }catch let err {
            print(err.localizedDescription)
        }
    }
    
}
