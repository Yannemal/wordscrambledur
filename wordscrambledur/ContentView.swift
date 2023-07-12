//
//  ContentView.swift
//  wordscrambledur - Project 5
//  Day29 /100DaysOfSwiftUI @TwoStraws Paul Hudson
//  Student: yannemal on 12/07/2023.
//

import SwiftUI

struct ContentView: View {
    // MARK: - DATA
    
    var body: some View {
        //List 1
        List{
            Text("Hello Earth")
            Text("Hello Moon")
            Text("Hello International SpaceStation")
            
            Section("dynamic bit")  {
                ForEach(0..<5) {
                    Text("Dynamic Row of List \($0)")
                }
            }
            Section {
                Text("mix and match sections in one List but not Form: thats a special kind of list. 1 list per view")
            }
            
            Text("another hardcoded row")
            Text("another hardcoded row, no problem")
        }
        .listStyle(.sidebar)
      
        
        
        
    } //end body View
} // ContentView

// MARK: - METHODS


// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
