//
//  ContentView.swift
//  wordscrambledur - Project 5
//  Day29 /100DaysOfSwiftUI @TwoStraws Paul Hudson
//  Student: yannemal on 12/07/2023.
//

import SwiftUI

struct ContentView: View {
    // MARK: - DATA
    let starWarsCharacters = ["Luke Skywalker", "Darth Vader", "Princess Leia Organa", "Han Solo", "Chewbacca", "C-3PO", "R2-D2", "Obi-Wan Kenobi", "Yoda"]
    // collection of words earlier attempts
    @State private var usedWords = [String]()
    // will be word player is spelling from
    @State private var rootWord = ""
    // new attempt by player to bind to textfield
    @State private var newWord = ""
    
    // if array has an even number of indexes set to true
    private var even : Bool {
        return usedWords.count % 2 == 0
    }
        
        
    
    var body: some View {

        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                          
                            Image(systemName: even ? "\(word.count).circle" : "\(word.count).circle.fill")
                            Text(word)
                          }
                        }
                    }
                
            } // end NavStack
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
        }
      
        //example List 2
        
//        List(starWarsCharacters.sorted(), id: \.self) {
//            Text($0)
//        }
        
    } //end body View
    
    // MARK: - METHODS
    func addNewWord() {
        // taking the newWord from TextField entry > lowerCase > no whiteSpace
        let answer = newWord.lowercased()
        let answer2 = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        // make sure theres a minimum requirement
        guard answer2.count > 0 else { return }
        // add answer to array at 0 so it comes in at the top of the List always in view
        withAnimation {
            usedWords.insert(answer2, at: 0)
        }
            //reset textField
        newWord = ""
        
        
    }
    
    
    func loadFile() {
        if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                // we loaded the file into a String
            }
        }
    }
    
    
} // ContentView


// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
