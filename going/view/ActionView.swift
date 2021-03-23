//
//  ActionView.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import Foundation
import SwiftUI

struct ActionView: View {
    
    var player = TextPlayer()
    
    @ObservedObject var model = Model()
    
    var body: some View {
        
        Button(action: {
            
            model.forEach([1,2,3,4], next: { (v, next) in
                model.forEach(model.beeps, next: { (beep, next) in
                    player.play(beep.text)
                    model.title = String(beep.time) + "秒"
                    model.sub_title = String(beep.text)
                    model.beep(2, finish: {
                        model.beep(beep.time) { (tic) in
                            if beep.timeBeep {
                                player.play(tic)
                            }
                            model.title = String(tic)
                        } finish: {
                            helper.wait(for: 1, callback: {
                                next()
                            })
                        }

                    })
                }, first: { (beep, start) in
                    player.play("第\(v)次") { _ in
                        start()
                    }
                }, last: { beep in
                    next()
                })

            }, first: nil, last: { v in
                model.title = "开始"
                model.sub_title = nil
            })
            
            
        }, label: {
            ZStack{
                Circle()
                    .frame(width: (UIScreen.main.bounds.width)/2, height: (UIScreen.main.bounds.width)/2)
                    .foregroundColor(.thinblue)
                
                Circle()
                    .frame(width: (UIScreen.main.bounds.width - 48)/2, height: (UIScreen.main.bounds.width - 48)/2)
                    .foregroundColor(.lightblue)
                
                VStack {
                    Text(model.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(2)
                        
                    
                    if let t = model.sub_title {
                        Text(t)
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }.frame(width: (UIScreen.main.bounds.width - 108)/2, height: (UIScreen.main.bounds.width - 108)/2)
                
                
            }
        })
        
    }
    
    class Model: ObservableObject {
        
        @Published var title = "开始"
        @Published var sub_title:String? = "?"
        @Published var beeps: [Beep] = [
            Beep(text: "蹦脚", time: 3, timeBeep: true),
            Beep(text: "勾脚", time: 3, timeBeep: true),
            Beep(text: "正抬腿", time: 3, timeBeep: true),
            Beep(text: "放松", time: 3, timeBeep: false)
        ]
        
        struct Beep {
            var text = ""
            var time = 1
            var timeBeep = false
        }
        
        func forEach<T>(
            _ arr: [T],
            from: Int = 0,
            next: @escaping ((T, @escaping () -> Void) -> Void),
            first: ((T, @escaping () -> Void) -> Void)?,
            last: ( (T) -> Void)?
        ) {
            if arr.count > 0 {
                if let f = first {
                    f(arr[0]) {
                        self.forEach(arr, next: next, first: nil, last: last)
                    }
                    return
                }
            }
            if from < arr.count {
                next(arr[from]) {
                    self.forEach(arr, from: from + 1, next: next, first: first, last: last)
                    
                    if (from + 1) == arr.count {
                        if let f = last {
                            f(arr[from])
                        }
                    }
                }
            }
        }
        
        
        func eachBeeps(from: Int = 0, next: @escaping ((Beep, @escaping () -> Void) -> Void), last: ((Beep) -> Void)?){
            if from < beeps.count {
                next(beeps[from]) {
                    self.eachBeeps(from: from + 1, next: next, last: last)
                    
                    if (from + 1) == self.beeps.count {
                        if let f = last {
                            f(self.beeps[from])
                        }
                    }
                }
            }
        }
        
        
        func beep(_ seconds: Int, next: ((Int) -> Void)? = nil, finish: (() -> Void)? = nil) {
            
            helper.wait(for: 1) {
                if let f = next {
                    f(seconds)
                }
                
                if seconds > 1 {
                    self.beep(seconds - 1, next: next, finish: finish)
                }else{
                    if let f = finish {
                        f()
                    }
                }
            }
            
        }
        
        
    }
}

#if DEBUG
struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView()
    }
}
#endif
