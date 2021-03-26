//
//  BeepSheet.swift
//  going
//
//  Created by gzhang on 2021/3/24.
//

import Foundation
import SwiftUI
import Combine

struct BeepSheet: View {
    
    @State var text: String = ""
    @State var time: String = ""
    @State var beep = false
    
    var source: Beep?
    var onSave: ((Beep?, String, Int, Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 0){
            Form {
                Section() {
                    HStack{
                        Text("名称").bold().frame(width: UIScreen.main.bounds.width/4)
                        TextField("请输入名称", text: $text)
                    }
                }
                Section() {
                    HStack{
                        Text("时长(秒)").bold().frame(width: UIScreen.main.bounds.width/4)
                        TextField("输入延时秒数, 例如: 3", text: $time)
                            .keyboardType(.numberPad)
                            .onReceive(Just(time)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.time = filtered
                                }
                                
                            }
                    }
                }
                
                Section {
                    HStack{
                        Text("是否读秒").bold().frame(width: UIScreen.main.bounds.width/4)
                        // TextField("请输入时间, 例如: 3", text: $time)
                        Toggle("", isOn: $beep)
                    }
                }
                
            }
            
            Divider()
            HStack{
                Button(action: {
                    
                }, label: {
                    Text("保存并覆盖同名项").bold().foregroundColor(.white).font(.footnote)
                })
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.lightred)
                .cornerRadius(18)
                .padding()
                Spacer()
                Button(action: {
                    if let save = onSave, let t = Int(time) {
                        save(source, text, t, beep)
                    }
                }, label: {
                    Text("保存").bold().foregroundColor(.white).font(.footnote)
                })
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.green)
                .cornerRadius(18)
                .padding()
                
            }
        }
        .navigationBarTitle(Text("Setting"))
        .onAppear{
            if let s = source {
                text = s.text
                time = String(s.time)
                beep = s.timeBeep
            }
        }
    }
    
}


#if DEBUG
struct BeepSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        BeepSheet()
    }
}
#endif
