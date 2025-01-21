//
//  MainTabbedView.swift
//  Habita
//
//  Created by Gary on 1/1/2025.
//

import Foundation
import SwiftUI

extension TabView{
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .primary : .gray)
                .frame(width: 20, height: 20)
            if isActive{
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .primary : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(isActive ? Color.primary.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}
