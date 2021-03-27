//
//  ActionView.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import Foundation
import SwiftUI

struct ActionView: View {
    
    // @Environment(\.managedObjectContext) private var viewContext
    
    var coreData: CoreDataService = .going
    var player = TextPlayer()
    
    @ObservedObject var model = Model()
    
    @State var session:Model.Session?
    @State var beeping_idx: Int?
    
    @State var isEditBeep = false
    @State var editIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack{
                if let s = session {
                    ZStack(){
                        HStack(spacing:0){
                            Text(s.title ?? "")
                                .bold()
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                        }
                        
                        HStack(alignment: .bottom, spacing: 0){
                            NavigationLink(
                                destination: ReportView(),
                                label: {
                                    Image(systemName: "waveform.path.ecg")
                                        .padding(.horizontal, 8)
                                }).padding(.top, 16)
                            Spacer()
                        }
                        
                        HStack(alignment: .bottom, spacing: 0){
                            Spacer()
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "square.and.pencil")
                                    .padding(.horizontal, 8)
                            }).padding(.top, 16)
                            
                        }
                    }
                    //                    Divider()
                }
                
                VStack(spacing:0){
                    Spacer()
                    VStack{
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
                                    .frame(width: (UIScreen.main.bounds.width)*6/11, height: (UIScreen.main.bounds.width)*2/3)
                                    .foregroundColor(.thinblue)
                                
                                Circle()
                                    .frame(width: (UIScreen.main.bounds.width - 48)*6/11, height: (UIScreen.main.bounds.width - 48)*2/3)
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
                        if model.state == .running {
                            Button(action: {
                                model.state = .stop
                            }, label: {
                                Image(systemName: "stop.circle").font(.title)
                            })
                        }else{
                            Image(systemName: "stop.circle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }.padding(.vertical, 32)
                    Spacer()
                    if model.state == .ready {
                        HStack {
                            Button(action: {
                                isSelectSession = true
                            }, label: {
                                Image(systemName: "ant")
                            })
                            
                        }.padding()
                    }else{
                        Image(systemName: "ant").padding()
                    }
                    
                }
                .onAppear(){
                    SportTime.shared.initAppData()
                    
                    model.reloadData()
                    
                    if session == nil && model.sessions.count > 0 {
                        session = model.sessions[0]
                    }
                    // SportTime.shared.cleanAllData()
                    
                    (ReportGenerator()).generate(start: Int(Date().timeIntervalSince1970 - 86400*2))
                    //isSelectSession = true
                    
                }
                
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditBeep, content: {
                // BeepSheet()
//                if let s = session , let ei = editIndex {
//                    BeepSheet(source: s.beeps[ei])
//                }
            })
            .sheet(isPresented: $isSelectSession, content: {
                SessionSelector(
                    selected: session?.title,
                    sessions: model.sessions,
                    isShow: $isSelectSession
                ){ selected in
                    if let s = model.sessions.first(where: { $0.title == selected }) {
                        session = s
                        if model.state != .ready {
                            model.state = .stop
                        }
                        
                    }
                }
            })
        }
        
    }
    
    func learning(session: Model.Session){
        
        let repeats: [Int] = (1...session.repeats).map({$0})
        model.state = .running
        model.forEach(repeats, next: { (v, next) in
            
            model.forEach(session.beeps, next: { (beep, next) in
                
                let start_time = Int64(Date().timeIntervalSince1970)
                
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
                        coreData.query(request: BeepLog.fetchRequest()) { (query) in
                            if let beepLog = query.instance() {
                                beepLog.uuid = beep.uuid.description
                                beepLog.name = beep.text
                                beepLog.start_time = start_time
                                beepLog.end_time = Int64(Date().timeIntervalSince1970)
                                query.flush()
                            }
                        }
                        helper.wait(for: 1, callback: {
                            next()
                        })
                    }
                    
                })
                
            }, first: { (beep, start) in
                if repeats.count > 1 {
                    if (repeats.count < 20 || v % 10 == 0) {
                        player.play("第\(v)次") { _ in
                            start()
                        }
                    }else {
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
        
        var coreData = CoreDataService.going
        
        enum State: String {
            case stop, hold, ready, running, holding
        }
        
        @Published var state: State = .ready
        @Published var title = "开始"
        @Published var sub_title:String? = ""
        @Published var beeps: [Beep] = [
            Beep(text: "3秒", time: 3, timeBeep: true),Beep(text: "勾脚", time: 3, timeBeep: true),
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
                    Beep(text: "俯", time: 1, timeBeep: false),
                    Beep(text: "撑", time: 1, timeBeep: false)
                ],
                repeats: 10,
                title: "俯卧撑训练",
                interval_beep: nil
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
        
        func reloadData(){
            coreData.query(request: BeepSession.fetchRequest(), query: { query in
                let beepSessions = query.findBy()
                
                self.sessions = beepSessions.map({ s in
                    return Session(
                        beeps: s.beeps,
                        repeats: s.repeats,
                        title: s.name,
                        interval_beep: s.iterval_beep
                    )
                })
            })
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
            
        }
        
        
    }
    
    @State var isSelectSession = false
    struct SessionSelector: View {
        
        @State var selected: String? = nil
        @State var custom: String = ""
        
        var sessions: [Model.Session]
        @Binding var isShow: Bool
        var onSelect: ((String) -> Void)?
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack{
                    Text("请选择")
                        .foregroundColor(.gray)
                }.padding(.top)
                
                
                ScrollView {
                    BadgeSelector(
                        badges: sessions.filter({ $0.title != nil }).map({ $0.title! }),
                        selected: selected,
                        onSelect: { (text) in
                            selected = text
                            if let f = onSelect {
                                f(text)
                                isShow = false
                            }
                        }
                    )
                }
                
                Spacer()
                Divider()
                VStack(spacing: 0){
                    Text("以上均没有想要的, 请点击”+“按钮, 创建")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Button(action: {
                        isShow = false
                        
                    }, label: {
                        Image(systemName: "plus")
                    }).padding()
                }
            }.padding(.horizontal)
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
