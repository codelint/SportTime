//
//  PlanListView.swift
//  going
//
//  Created by gzhang on 2021/3/21.
//

import Foundation
import SwiftUI
import SwiftUICharts


struct ReportView: View {
    
    var coreData = CoreDataService.going
    @State var reports =  [BeepReport]()
    
    struct DateReport: View {
        
        var report: BeepReport
        
        struct Item: View {

            var k: String
            var v: String

            var body: some View {
                HStack {
                    Text(k).font(.footnote)
                    Spacer()
                    Text(v).bold().font(.footnote)
                }
                .padding(.top, 4)
            }

        }
        
        var body: some View {
            VStack{
                HStack{
                    Text(report.label ?? "?").bold().font(.title3)
                    Spacer()
                }
                // Item(k: "项目", v: report.label ?? "")
                Item(k: "次数", v: report.number.description)
                Item(k: "耗时", v: "\(report.elapsed.description) 秒")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 13)
            
        }
    }
    
    var body: some View {
        ScrollView{
            VStack {
                
                ForEach(reports, id: \.label) { report in
                    DateReport(report: report)
                }
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(Color.lightgray)
        .navigationTitle(Text(Date().dateString))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(){
            reports = coreData.findBy(
                request: BeepReport.fetchRequest(),
                conds: ["timeline": Date().dateString]
            )
        }
        
    }
    
    
    
}


#if DEBUG
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
        // ActionView()
    }
}
#endif
