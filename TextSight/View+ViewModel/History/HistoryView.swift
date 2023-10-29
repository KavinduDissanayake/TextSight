//
//  HistoryView.swift
//  TextSight
//
//  Created by Kavindu Dissanayake on 2023-10-29.
//

import SwiftUI

struct HistoryView: View {
    //MARK: - PROPERITY
    
    //MARK: - VIEW
    var body: some View {
        
        ZStack {
            Theme.backgroundColor
            
            VStack(spacing:0){
                GeometryReader { geometry in
                    
                    ScrollView(.vertical , showsIndicators: false) {
                        VStack(alignment: .center, spacing: 20) {
                            
                            
                            
                            Spacer()
                            
                        }//:VStack
                        .frame(minHeight: geometry.size.height)
                    }//:ScrollView
                    .frame(width: geometry.size.width)
                }//:GeometryReader
            }//:VStack
            
            
            
        }//:ZStack
        .navigationTitle("History")
        .edgesIgnoringSafeArea(.all)
    }
    
}
//MARK: PREVIEW


#Preview {
    HistoryView()
}
