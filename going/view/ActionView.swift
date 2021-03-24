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
    
    @State var session:Model.Session?
    @State var beeping_idx: Int?
    
    var body: some View {
        NavigationView {
            VStack{
                if let s = session {
                    HStack(spacing:0){
                        Text(s.title ?? "")
                            .bold()
                            .font(.title3).padding(.top, 16)
                    }
                    
                    Divider()
                }
                ScrollView(showsIndicators:false){
                    VStack(spacing:0){
                        BadgeSelector(
                            badges: model.sessions.map({$0.title ?? ""}),
                            selected: session?.title ?? "",
                            onSelect: { (text) in
                                if let s = model.sessions.first(where:{ (session) -> Bool in
                                    return session.title != nil && session.title! == text
                                }) {
                                    session = s
                                    if model.state != .ready {
                                        model.state = .stop
                                    }
                                }
                            }
                        ).padding(.horizontal)
                        
                        Button(action: {
                            
                            switch model.state {
                            case .ready:
                                if let s = session {
                                    self.learning(session: s)
                                }
                            case .running :
                                model.state = .hold
                            case .holding:
                                fallthrough
                            case .hold:
                                model.state = .running
                            case .stop:
                                break
                            }
                            
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
                        .padding(.vertical, 32)
                            
                        if let s = session {
                            
                            BadgeSelector(
                                s.beeps.enumerated().map({ (index, beep) in
                                    return BadgeItem(id: String(index), name: "\(beep.text)(\(beep.time)s)", value: beep.text)
                                }),
                                disabledBadges: [],
                                selected: beeping_idx == nil || session == nil ? nil : BadgeItem(
                                    id: String(beeping_idx!),
                                    name: session!.beeps[beeping_idx!].text,
                                    value: session!.beeps[beeping_idx!].text
                                )
                            ) { (item) in
                                
                            }.padding(.horizontal)
                            
                        }
                        
                        //Spacer()
                    }
                    .onAppear(){
                        if session == nil && model.sessions.count > 0 {
                            session = model.sessions[0]
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        
    }
    
    func learning(session: Model.Session){
        
        let repeats: [Int] = (1...session.repeats).map({$0})
        model.state = .running
        model.forEach(repeats, next: { (v, next) in
            
            model.forEach(session.beeps, next: { (beep, next) in
                
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
                if repeats.count > 1 {
                    player.play("第\(v)次") { _ in
                        start()
                    }
                }
            }, last: { beep in
                // next()
                
                if repeats.count > 1 {
                    if let interval = session.interval_beep {
                        print("repeat: \(v) / \(model.state) / \(interval.time)")
                        
                        if interval.time > 0 && v < repeats.count && model.state == .running {
                            player.play(interval.text)
                            model.beep(interval.time, next: { tic in
                                if interval.timeBeep {
                                    player.play(tic)
                                }
                                model.title = String(tic)
                            }, finish: {
                                helper.wait(for: interval.time, callback:next)
                            })
                        }else{
                            next()
                        }
                        
                    }else{
                        next()
                    }
                    
                    
                }else{
                    next()
                }
            })
        },
        first: nil,
        last: { v in
            model.title = "开始"
            model.sub_title = nil
            player.play("结束")
            model.state = .ready
        })
    }
    
    class Model: ObservableObject {
        
        enum State: String {
            case stop, hold, ready, running, holding
        }
        
        @Published var state: State = .ready
        @Published var title = "开始"
        @Published var sub_title:String? = ""
        @Published var beeps: [Beep] = [
            Beep(text: "3秒", time: 3, timeBeep: true),Beep(text: "勾脚", time: 3, timeBeep: true),
//            Beep(text: "正抬腿", time: 15, timeBeep: true),
//            Beep(text: "侧抬腿", time: 15, timeBeep: true),
//            Beep(text: "背抬腿", time: 15, timeBeep: true),
            Beep(text: "放松", time: 5, timeBeep: true)
        ]
        
        @Published var stopping = false
        
        @Published var sessions: [Session] = [
            Session(
                beeps: [Beep(text: "开始", time: 3, timeBeep: true),Beep(text: "开始", time: 3, timeBeep: true)],
                repeats: 2,
                title: "倒计时3秒",
                interval_beep: Beep(text: "放松", time: 3, timeBeep: true)
            ),
            Session(
                beeps: [
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                    Beep(text: "俯", time: 1, timeBeep: false),Beep(text: "撑", time: 1, timeBeep: false),
                ],
                repeats: 2,
                title: "俯卧撑训练",
                interval_beep: Beep(text: "放松", time: 5, timeBeep: true)
            ),
            Session(beeps: [
                Beep(text: "蹦脚", time: 3, timeBeep: true),
                Beep(text: "勾脚", time: 3, timeBeep: true)
            ], repeats: 100, title: "踝泵训练"),
            Session(
                beeps: [
                    Beep(text: "正抬腿", time: 15, timeBeep: true),
                ],
                repeats: 15, title: "正直抬腿",
                interval_beep: Beep(text: "放松", time: 5, timeBeep: true)
            ),
            Session(beeps: [
                Beep(text: "侧抬腿", time: 15, timeBeep: true),
            ], repeats: 15, title: "侧抬腿", interval_beep: Beep(text: "放松", time: 5, timeBeep: true)),
            Session(beeps: [
                Beep(text: "背抬腿", time: 15, timeBeep: true),
            ], repeats: 15, title: "背抬腿", interval_beep: Beep(text: "放松", time: 5, timeBeep: true))
            
        
        ]
        
        struct Session {
            var beeps = [Beep]()
            var repeats = 1
            var title: String?
            
            var interval_beep: Beep? = nil
        }
        
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
            switch state {
            case .hold,.holding:
                helper.wait(for: 0.1) {
                    self.forEach(arr, from: from, next: next,first: first,  last: last)
                }
                state = .holding
                return
            case .stop:
                // state = .ready
                if let item = arr.last, let f = last {
                    f(item)
                }
                return
            case .ready, .running:
                print("ready/running")
                state = .running
            }
            
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
        
        
//        func eachBeeps(from: Int = 0, next: @escaping ((Beep, @escaping () -> Void) -> Void), last: ((Beep) -> Void)?){
//            if from < beeps.count {
//                next(beeps[from]) {
//                    self.eachBeeps(from: from + 1, next: next, last: last)
//
//                    if (from + 1) == self.beeps.count {
//                        if let f = last {
//                            f(self.beeps[from])
//                        }
//                    }
//                }
//            }
//        }
        
        
        func beep(_ seconds: Int, next: ((Int) -> Void)? = nil, finish: (() -> Void)? = nil) {
            let arr = (1...seconds).map({$0}).sorted(by: {$0 > $1})
            
            forEach(arr, next: { (sec, loop) in
                helper.wait(for: 1) {
                    if let f = next {
                        f(sec)
                    }
                    // self.beep(sec, next: next, finish: finish)
                    loop()
                }
            }, first: nil, last: { sec in
                if let f = finish {
                    f()
                }
            })
//            helper.wait(for: 1) {
//                if let f = next {
//                    f(seconds)
//                }
//                if seconds > 1 {
//                    self.beep(seconds - 1, next: next, finish: finish)
//                }else{
//                    if let f = finish {
//                        f()
//                    }
//                }
//            }
            
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
