//
//  ContentView.swift
//  LikeButtonSwiftUI
//
//  Created by Daniel Carvajal on 23-05-22.
//

import SwiftUI

struct ContentView: View {
    private let reactions: [(String,String)] = [("star.fill", "Estrella"),("pencil","Lápiz"),("scribble","Rayo"),
        ("heart.text.square.fill", "Carta"),("sun.min.fill", "Sol")]
    
    var body: some View {
        ReactionsView(reactions){ reaction in
            print(reaction.text)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
