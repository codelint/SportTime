//
//  Badages.swift
//  samulala
//
//  Created by gzhang on 2021/2/25.
//

import Foundation
import SwiftUI

struct BadgeLabel: View{
    var labelName = "label"
    var body: some View{
        Text(labelName)
            .font(.caption2)
            .padding(.all, 5)
            .foregroundColor(.white)
            .cornerRadius(8)
            .background(Color.gray)
            .lineLimit(1)
    }
}

struct BadgeItem: Equatable {
    let _id: String = UUID().description
    var id: String
    var name: String
    var value: String
    
    init( id: String, name: String, value: String){
        self.id = id
        self.name = name
        self.value = value
    }
    
    init(name: String){
        self.id = name
        self.name = name
        self.value = name
    }
    
    static func == (a: BadgeItem, b: BadgeItem) -> Bool {
        return a._id == b._id
    }
}


struct LineWrapper<Content: View>: View {
    
    // var names = ["..."]
    var items = [BadgeItem]()
    
    let item: ((BadgeItem) -> Content)!
    
    @State private var totalHeight = CGFloat.zero

    init(names: [String], @ViewBuilder content: @escaping (_ name: String) -> Content) {
        // self.names = names
        self.items = names.map({ BadgeItem(id: UUID().description, name: $0, value: $0) })
        self.item = { item in
            content(item.name)
        }
    }
    
    init(items: [BadgeItem], @ViewBuilder content: @escaping (_ item: BadgeItem) -> Content) {
        // self.names = items.map({ $0.name })
        self.items = items
        self.item = content
    }


    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }.frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.id) { item in
                self.item(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
//                        print("当前width",width)
//                        print("当前d.width",d.width)
//                        print("当前g.size.width",g.size.width)
                        let result = width
                        if item == self.items.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if item == self.items.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
                // print("totalHeight: ", rect.size.height)
            }
            return .clear
        }
    }
    
}

struct Badges: View {
    var names = ["..."]
    var items = [BadgeItem]()
    
    var backgroundColor: Color = Color.blue
    var foregroundColor: Color = Color.white
    var font: Font? = Font.footnote
    var cornerRadius: CGFloat = 5
    var selectedColor: Color?
    var selected: String?
    
    func text(_ name: String) -> some View {
        Text(name)
            .padding(.all, 5)
            .font(font)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
    }
    
    var body: some View {
        
        if items.count > 0 {
            LineWrapper(items: items){ (item: BadgeItem) in
                text(item.name)
            }
        }else {
            LineWrapper(names: names){ (name: String) in
                text(name)
            }
        }
        
    }
}

struct BadgeSelector: View {

    var badges = [BadgeItem]()
    var disabledBadges = [BadgeItem]()
    var selected: BadgeItem?
    
    var onSelect: ((_ badge: BadgeItem) -> Void)?
    
    init(badges: [String], disabledBadges: [String] = [String](), selected: String? = nil, onSelect: ((_ badge: String) -> Void)? = nil){
        self.badges = badges.map({ BadgeItem(id: $0, name: $0, value: $0) })
        self.disabledBadges = disabledBadges.map({ BadgeItem(id: $0, name: $0, value: $0) })
        if let s = selected {
            if let b = self.badges.first(where: { $0.name == s }) {
                self.selected = b
            }else{
                self.selected = BadgeItem(id: s, name: s, value: s)
            }
        }
        if let listen = onSelect {
            self.onSelect = { badge in
                listen(badge.name)
            }
        }
    }
    
    init(_ badges: [BadgeItem], disabledBadges: [BadgeItem] = [BadgeItem](), selected: BadgeItem? = nil, onSelect: ((_ badge: BadgeItem) -> Void)? = nil){
        
        self.badges = badges
        self.disabledBadges = disabledBadges
        self.selected = selected
        self.onSelect = onSelect
    }
    
    var body: some View {
        LineWrapper(items: self.badges){ item in
            Button(action: {
                if self.disabledBadges.contains(item) {
                    return
                }
                if self.onSelect != nil {
                    self.onSelect!(item)
                }
            }){
                
                Text(item.name)
                    .bold()
                    .font(.footnote)
                    .padding(.all, 5)
                    .frame(minWidth: 48)
                    .foregroundColor(self.disabledBadges.contains(item) ? .gray : .white)
                    .background(selected == item ? Color.orange : (self.disabledBadges.contains(item) ? Color.lightgray : Color.gray))
                    .cornerRadius(5)
                
            }
        }
        // .padding(.vertical, 8)
    }
    
}
