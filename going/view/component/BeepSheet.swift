//
//  BeepSheet.swift
//  going
//
//  Created by gzhang on 2021/3/24.
//

import Foundation
import SwiftUI
import Combine
import PopupView

struct BeepSheet: View {
    
    @State var text: String = ""
    @State var time: String = "1"
    @State var beep = true
    
    @State var title: String = ""
    @State var times: String = "1"
    
    // @State var iterval: Beep?
    @State var beeps: [Beep] = []
    
    @State var presentBeepEditor = false
    @State var editBeep: Beep?
    
    var coreData = CoreDataService.going
    
    var session: BeepSession?
    var onSave: ((String) -> Void)?
    
    init (onSave: ((String) -> Void)? = nil) {
        self.onSave = onSave
    }
    
    init(session: BeepSession, onSave: ((String) -> Void)?){
        self.session = session
        self.onSave = onSave
    }
    
    init(title: String, onSave: ((String) -> Void)?){
        
        self.onSave = onSave
        if let s = coreData.findByOne(request: BeepSession.fetchRequest(), conds: ["name": title]) {
            session = s
        }
        
    }
    
    struct LabelText: View {
        var text: String = ""
        
        init(_ t: String){
            text = t
        }
        var body: some View {
            HStack{
                Spacer()
                Text(text)
                    .font(.subheadline)
            }
            .padding(.trailing, 4)
            .frame(width: UIScreen.main.bounds.width/4)
            
        }
    }
    
    struct NumberField: View {
        
        var tip: String
        @Binding var value: String
        
        var body: some View {
            TextField(tip, text: $value)
                .keyboardType(.numberPad)
                .onReceive(Just(value)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        value = filtered
                    }
                    
                }
        }
    }
    
    struct FieldSection<Content:View>: View {
        
        var title: String = ""
        var padding: CGFloat = 8
        var content: () -> Content
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                if title.count > 0 {
                    Text(title).font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                }
                content()
                    .padding(self.padding)
                    .background(Color.white)
            }.padding(.vertical, 8)
        }
    }
    
    struct BeepRow: View {
        
        var beep: Beep
        
        var onEdit: ((Beep) -> Void)?
        var onCopy: ((Beep) -> Void)?
        var onDelete: ((Beep) -> Void)?
        
        var body: some View {
            
            VStack(spacing: 0){
                HStack(spacing: 0) {
                    Button(action: {
                        if let f = onDelete {
                            f(beep)
                        }
                    }, label: {
                        Image(systemName: "minus.circle")
                    }).foregroundColor(.red)
                    .padding(.trailing, 8)
                    
                    HStack(spacing: 0){
                        Image(systemName: beep.timeBeep ? "speaker.2" : "speaker.slash")
                        Text(" / ")
                        
                        Text("\(beep.time)秒")
                        Text(" / ")
                        Text("\(beep.text)")
                            .lineLimit(1)
                    }.foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        if let f = onCopy {
                            f(beep)
                        }
                    }, label: {
                        Image(systemName: "doc.on.doc")
                    }).padding(.horizontal, 8)
                    Button(action: {
                        if let f = onEdit {
                            f(beep)
                        }
                    }, label: {
                        Image(systemName: "square.and.pencil")
                    }).padding(.horizontal, 8)
                    
                }
                .padding(12)
                Divider()
            }.frame(width: UIScreen.main.bounds.width)
        }
    }
    
    
    struct BeepEditDialog: View {
        
        @State var beep: Beep = Beep(text: "", time: 1, timeBeep: true)
        
        @State var time: String = ""
        @State var text: String = ""
        @State var ring: Bool = false
        
        var history: [Beep] = []
        
        var onReturn: ((Beep?, String?) -> Void)?
        
        var body: some View {
            VStack(spacing: 0){
                Color(.gray).opacity(0.8)
                //Spacer()
                
                VStack{
                    Text("请输入").foregroundColor(.gray).font(.footnote)
                    Divider().padding(.bottom, 3)
                    HStack{
                        LabelText("播放文字")
                        TextField("请输入名称", text: $text)
                    }

                    HStack{
                        LabelText("时长(秒)")
                        NumberField(tip: "输入延时秒数, 例如: 3", value: $time)
                    }

                    HStack{
                        LabelText("是否读秒")
                        Toggle("", isOn: $ring)
                    }
                    
                    Divider()
                    if history.count > 0 {
                        VStack{
                            HStack {
                                Text("从历史中复制:").font(.caption).foregroundColor(.gray)
                                Spacer()
                            }
                            BadgeSelector(history.map({ beep in
                                return BadgeItem(id: beep.uuid, name: "\(beep.text)(\(beep.time)秒)", value: beep.text)
                            }).uniq(key: { (item: BadgeItem) in
                                return item.name
                            }), onSelect: { (badge: BadgeItem) in
                                
                                if let b = history.first(where: { $0.uuid == badge.id }) {
                                    beep.text = b.text
                                    beep.time = b.time
                                    beep.timeBeep = b.timeBeep
                                    time = String(b.time)
                                    text = b.text
                                    ring = b.timeBeep
                                }
                            })
                            Divider()
                        }
                    }
                    
                    HStack{
                        Button(action: {
                            if let f = onReturn {
                                f(nil, nil)
                            }
                        }, label: {
                            Text("取消").foregroundColor(.white)
                        })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray)
                        .cornerRadius(5.0)
                        Spacer()
                        if beep.text.count > 0 {
                            Button(action: {
                                if let f = onReturn {
                                    let old = beep.text
                                    beep.time = Int(time) ?? beep.time
                                    beep.text = text
                                    beep.timeBeep = ring
                                    f(beep, old)
                                }
                            }, label: {
                                Text("同名批量修改").foregroundColor(.lightgray)
                            }).padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(5.0)
                        }
                        Button(action: {
                            if let f = onReturn {
                                beep.time = Int(time) ?? beep.time
                                beep.text = text
                                beep.timeBeep = ring
                                f(beep, nil)
                            }
                        }, label: {
                            Text("确定").foregroundColor(.white)
                        })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(5.0)
                    }
                    
                    
                }
                .padding(8)
                .background(Color.white)
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear(){
                time = String(beep.time)
                text = beep.text
                ring = beep.timeBeep
            }
        }
    }
    
    var body: some View {

        ZStack{
            
            VStack(spacing: 0){
                
                ScrollView(showsIndicators: false){
                FieldSection(title: "基本信息") {
                    VStack {
                        HStack{
                            LabelText("名称")
                            TextField("请输入名称", text: $title)
                        }
                        HStack{
                            LabelText("重复次数")
                            NumberField(tip:"1", value: $times)
                        }
                    }
                }
                
                FieldSection(title: "重复间隔设置") {
                    VStack{
                        HStack{
                            LabelText("播放文字")
                            TextField("请输入名称", text: $text)
                        }
                        
                        HStack{
                            LabelText("时长(秒)")
                            NumberField(tip: "输入延时秒数, 例如: 3", value: $time)
                        }
                        
                        HStack{
                            LabelText("是否读秒")
                            Toggle("", isOn: $beep)
                        }
                    }
                }
                
                if beeps.count > 0 {
                    FieldSection(title: "计时序列", padding: 0){
                        ForEach(beeps){ beep in
                            BeepRow(
                                beep: beep,
                                onEdit: { beep in
                                    editBeep = beep
                                    withAnimation {
                                        presentBeepEditor = true
                                    }
                                }, onCopy: { beep in
                                    beeps.append(Beep(text: beep.text, time: beep.time, timeBeep: beep.timeBeep))
                                }, onDelete: { beep in
                                    if let idx = beeps.firstIndex(where: { $0.uuid == beep.uuid }) {
                                        beeps.remove(at: idx)
                                    }
                                    
                                }
                            )
                        }
                    }
                }
                Button(action: {
                    editBeep = Beep()
                    withAnimation {
                        presentBeepEditor = true
                    }
                }, label: {
                    Text("增加计时单位").font(.footnote)
                })
                Spacer()
                }
                Divider()
                HStack{
                    Spacer()
                    Button(action: {
                            
                        if title.count < 1 || beeps.count < 1 {
                            return
                        }
                        
                        coreData.query(request: BeepSession.fetchRequest(), query: { query in
                            let exist = query.findByOne(conds: ["name": title])
                            
                            if exist != nil
                                && ((session != nil && exist!.name != session!.name) || session == nil) {
                                return
                            }
                            
                            if let s = exist == nil ? query.instance() : exist {
                                s.name = title
                                s.times = Int64(times) ?? 1
                                s.iterval_beep = Beep(text: text, time: Int(time) ?? 1, timeBeep: beep)
                                s.beeps = beeps
                                query.flush()
                                //onSave
                                if let save = onSave {
                                    save(title)
                                }
                            }else{
                                //error
                            }
                        })
                            
                            // save(source, text, t, beep)
                        // }
                    }, label: {
                        Text("保存").bold().foregroundColor(.white).font(.footnote)
                    })
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.green)
                    .cornerRadius(18)
                    .padding()
                    
                }.background(Color.white)
            }
            
            if presentBeepEditor {
                BeepEditDialog(
                    beep: editBeep ?? Beep.empty,
                    history: beeps,
                    onReturn: { (result, title) in
                        if let beep = result {
                            if !beeps.contains(where: { $0.uuid == beep.uuid }) {
                                beeps.append(beep)
                            }
                            
                            if let tit = title {
                                for b in beeps.filter({ $0.text == tit }) {
                                    b.time = beep.time
                                    b.timeBeep = beep.timeBeep
                                    b.text = beep.text
                                }
                            }
                        }
                        withAnimation {
                            presentBeepEditor = false
                        }
                        
                    }
                )
                .transition(.moveAndFade)
            }
            
            
         
        }.background(Color.lightgray)
        .navigationBarTitle(Text("输入计时信息"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            if let s = session {
                
                if let b = s.iterval_beep {
                    text = b.text
                    time = String(b.time)
                    beep = b.timeBeep
                }
                
                title = s.name ?? ""
                times = String(s.times)
                // iterval = s.iterval_beep
                beeps = s.beeps
                
            }
            // presentBeepEditor = true
        }
        
            
        
      
    }
    
}


#if DEBUG
struct BeepSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        BeepSheet(title: "俯卧撑训练") { (title) in
            //todo
        }
    }
}
#endif
