//
//  ActionView.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import Foundation
import SwiftUI

struct ActionView: View {
    
    var coreData: CoreDataService = .going
    var player = TextPlayer()
    
    @ObservedObject var model = Model()
    
    @State var session:Model.Session?
    
    @State var beeping_idx: Int?
    
    @State var isEditBeep = true
    @State var editIndex: Int? = nil
    
    @State var isEditSessoin = false
    
    var sessionTitle: String {
        return self.session?.title ?? ""
    }
    
    var body: some View {
        // NavigationView {
        VStack{
            if let s = session {
                ZStack(){
                    HStack(spacing:0){
                        Text("\(s.title ?? "")")
                            .bold()
                            .font(.body).lineLimit(1)
                            .frame(maxWidth: UIScreen.main.bounds.width*0.6)
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                    }
                    
//                    HStack(alignment: .bottom, spacing: 0){
//                        if model.state == .ready {
//                            NavigationLink(
//                                destination: ReportView(),
//                                label: {
//                                    Image(systemName: "waveform.path.ecg")
//                                        .padding(.horizontal, 8)
//                                })
//                        }else{
//                            Image(systemName: "waveform.path.ecg").foregroundColor(.gray)
//                                .padding(.horizontal, 8)
//                        }
//                        Spacer()
//                    }.padding(.top, 16)
                    
                    HStack(alignment: .bottom, spacing: 0){
                        Spacer()
                        if model.state == .ready {
                            NavigationLink(
                                destination: BeepSheet(title: sessionTitle, onSave: { (tit) in
                                    isEditSessoin = false
                                    selectSession(tit)
                                }),
                                isActive: $isEditSessoin,
                                label: {
                                    Image(systemName: "square.and.pencil")
                                        .padding(.horizontal, 8)
                                }
                            )
                        }else{
                            Image(systemName: "square.and.pencil").foregroundColor(.gray).padding(.horizontal, 8)
                        }
                    }.padding(.top, 16)
                }
            }
            
            VStack(spacing:0){
                Spacer()
                VStack{
                    Button(action: {
                        
                        switch model.state {
                        case .ready:
                            if let s = session {
                                model.title = s.title == nil ? model.title : s.title!
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
                                Text(model.tip).font(.caption)
                                    .foregroundColor(.white)
                                Text(model.title)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .lineLimit(1)
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
                Group{
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
                }.font(.title)
                
            }
            .onAppear(){
                UIApplication.shared.isIdleTimerDisabled = true
                SportTime.shared.initAppData()
                
                model.reloadData()
                
                if session == nil && model.sessions.count > 0 {
                    session = model.sessions[0]
                }
                // SportTime.shared.cleanAllData()
                
                (ReportGenerator()).generate(start: Int(Date().timeIntervalSince1970 - 86400*2))
                //isSelectSession = true
                
                selectSession(SportTime.shared.option(name: .lastSessionTitle, def: session?.title ?? ""))
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isSelectSession, content: {
            SessionSelector(
                selected: session?.title,
                sessions: model.sessions,
                isShow: $isSelectSession
            ){ selected in
                selectSession(selected)
            }
        })
        //}
        
    }
    
    func selectSession(_ title: String){
        
        coreData.query(request: BeepSession.fetchRequest(), query: { query in
            if let s = query.findByOne(conds: ["name": title]) {
                
                self.session = Model.Session.from(beepSession: s)
                // self.title = self.session?.title
                helper.wait(for: 1, {
                    model.reloadSessions()
                })
                
                if model.state != .ready {
                    model.state = .stop
                }
                
            }
        })
        
    }
    
    func doBeep(beep: Beep, next: @escaping () -> Void){
        let start_time = Int64(Date().timeIntervalSince1970)
        
        player.play(beep.text){ _ in
            model.title = String(beep.time) + "???"
            model.sub_title = String(beep.text)
            
            model.beep(beep.time) { (tic) in
                if beep.timeBeep {
                    player.play(tic)
                }
                model.title = String(tic)
            } finish: {
                model.title = "0"
                helper.wait(for: 0.1){
                    coreData.query(request: BeepLog.fetchRequest()) { (query) in
                        if let beepLog = query.instance() {
                            beepLog.uuid = beep.uuid.description
                            beepLog.name = beep.text
                            beepLog.start_time = start_time
                            beepLog.end_time = Int64(Date().timeIntervalSince1970)
                            query.flush()
                        }
                    }
                }
                
                helper.wait(for: 1, callback: {
                    next()
                })
            }
        }
    }
    
    func learning(session: Model.Session){
        print("start to learning for session[\(session.title ?? "")]")
        let repeats: [Int] = session.repeats == 1 ? [1] : (1...session.repeats).map({$0})
        model.state = .running
        helper.wait(for: 1) {
            if let t = session.title {
                SportTime.shared.setOption(name: .lastSessionTitle, v: t)
                // print(SportTime.shared.option(name: .lastSessionTitle))
            }
        }
        
        model.forEach(repeats, next: { (v, next) in
            print("???\(v)???: beeps.count = \(session.beeps.count)")
            model.forEach(session.beeps, next: { (beep, next) in
                self.doBeep(beep: beep, next: next)
            }, first: { (beep, start) in
                helper.wait(for: session.delay){
                    if repeats.count > 1 {
                        model.tip = "???\(v)???"
                        if (repeats.count < 20 || v % 10 == 0) {
                            player.play("???\(v)???") { _ in
                                start()
                                // model.sub_title = "???\(v)???"
                            }
                        }else {
                            start()
                        }
                        
                    }else{
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
                                next()
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
        first: { (v, start) in
            if let beep = session.start_beep {
                doBeep(beep: beep, next: start)
            }else{
                start()
            }
        },
        last: { v in
            model.title = "??????"
            model.sub_title = nil
            model.tip = ""
            player.play("??????")
            print("??????")
            // model.state = .ready
            helper.wait(for: 1){
                model.state = .ready
                
            }
        })
    }
    
    class Model: ObservableObject {
        
        var coreData = CoreDataService.going
        
        enum State: String {
            case stop, hold, ready, running, holding
        }
        
        @Published var state: State = .ready
        @Published var title = "??????" {
            didSet {
                print(self.title)
            }
        }
        @Published var tip: String = ""
        @Published var sub_title:String? = ""
        @Published var beeps: [Beep] = [
            Beep(text: "3???", time: 3, timeBeep: true),Beep(text: "??????", time: 3, timeBeep: true),
            Beep(text: "??????", time: 5, timeBeep: true)
        ]
        
        @Published var stopping = false
        
        @Published var sessions: [Session] = [
            Session(
                beeps: [Beep(text: "??????", time: 3, timeBeep: true),Beep(text: "??????", time: 3, timeBeep: true)],
                repeats: 2,
                title: "?????????3???",
                interval_beep: Beep(text: "??????", time: 3, timeBeep: true)
            ),
            Session(
                beeps: [
                    Beep(text: "???", time: 1, timeBeep: false),
                    Beep(text: "???", time: 1, timeBeep: false)
                ],
                repeats: 10,
                title: "???????????????",
                interval_beep: nil
            ),
            Session(beeps: [
                Beep(text: "??????", time: 3, timeBeep: true),
                Beep(text: "??????", time: 3, timeBeep: true)
            ], repeats: 100, title: "????????????"),
            Session(
                beeps: [
                    Beep(text: "?????????", time: 15, timeBeep: true),
                ],
                repeats: 15, title: "????????????",
                interval_beep: Beep(text: "??????", time: 5, timeBeep: true)
            ),
            Session(beeps: [
                Beep(text: "?????????", time: 15, timeBeep: true),
            ], repeats: 15, title: "?????????", interval_beep: Beep(text: "??????", time: 5, timeBeep: true)),
            Session(beeps: [
                Beep(text: "?????????", time: 15, timeBeep: true),
            ], repeats: 15, title: "?????????", interval_beep: Beep(text: "??????", time: 5, timeBeep: true))
            
            
        ]
        
        struct Session {
            var beeps = [Beep]()
            var repeats = 1
            var title: String?
            var delay = 0
            
            var interval_beep: Beep? = nil
            var start_beep: Beep? = nil
            var end_beep: Beep? = nil
            
            static func from(beepSession: BeepSession) -> Session {
                return Session(
                    beeps: beepSession.beeps,
                    repeats: beepSession.repeats,
                    title: beepSession.name,
                    delay: Int(beepSession.delay),
                    interval_beep: beepSession.iterval_beep,
                    start_beep: beepSession.start_beep,
                    end_beep: beepSession.end_beep
                )
            }
        }
        
        func reloadData(){
            reloadSessions()
        }
        
        func reloadSessions(){
            coreData.query(request: BeepSession.fetchRequest(), query: { query in
                let beepSessions = query.findBy()
                
                self.sessions = beepSessions.map({ Session.from(beepSession: $0) })
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
                print("stop it")
                if let item = arr.last, let f = last {
                    f(item)
                    print("call last")
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
                helper.wait(for: 0.01) {
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
        
        @State var sessions: [Model.Session]
        @Binding var isShow: Bool
        var onSelect: ((String) -> Void)?
        
        @State var isAdd = false
        
        var body: some View {
            if !isAdd {
                VStack(spacing: 8) {
                    ZStack{
                        Text("?????????")
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
                        Text("????????????????????????, ????????????+?????????, ??????")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            withAnimation{
                                isAdd = true
                            }
                            
                        }, label: {
                            Image(systemName: "plus")
                        }).padding()
                    }
                }.padding(.horizontal)
            }else{
                BeepSheet { (tit) in
                    isAdd = false
                    let coreData = CoreDataService.going
                    coreData.query(request: BeepSession.fetchRequest()) { (query) in
                        if let s = query.findByOne(conds: ["name": tit]) {
                            sessions.append(Model.Session.from(beepSession: s))
                        }
                        
                    }
                }
            }
        }
    }
    
}

#if DEBUG
struct ActionView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            ActionView()
        }
    }
}
#endif
