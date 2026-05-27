//
//  EmptyView.swift
//  FlashRead
//
//  Placeholder empty view.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack {
            Image(systemName: "hare.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)
            Text("FlashRead")
                .font(.headline)
        }
        .frame(width: 300, height: 200)
    }
}
