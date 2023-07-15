//
//  ContentView.swift
//  wordscrambledur - Project 5
//  Day29 /100DaysOfSwiftUI @TwoStraws Paul Hudson
//  Student: yannemal on 12/07/2023.
//

import SwiftUI

struct ContentView: View {
   
    // MARK: - DATA

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
        
    // MARK: - body VIEW
    
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
                                .font(.largeTitle)
                            Text(word)
                                .italic()
                        }
                    }
                } // end Section
            } // end List
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        } // end NavStack
      
   
        
    } //end body View
    
    /* *********************************************************************************/
    /*                                                                                 */
    // MARK: - METHODS                                                                 //
    /*                                                                                 */
    /* *********************************************************************************/

    func addNewWord() {
        // Check 1 of the TextField entry > lowerCase > no whiteSpace
        let answer = newWord.lowercased().trimmingCharacters(in:  .whitespaces)
        //  Check 2 no separate words
        let answer2 = specificCharDeletion(word: answer)
        // make sure theres a minimum requirement
        guard answer2.count > 0 else { return }
        // add answer to array at 0 so it comes in at the top of the List always in view
        withAnimation {
            usedWords.insert(answer2, at: 0)
        }
            //reset textField
        newWord = ""
        
    }
    // https://www.codespeedy.com/remove-special-characters-from-a-string-in-swift/
    // added numbers and whiteSpace
    func specificCharDeletion(word: String)-> String {
        let specialChar = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", " ", "+", "-", "&", "|", "!", "(", ")", "{", "}", "[", "]", "^", "<", ">",
                           "~", "*", "?", ":",";", "\\", "@","`","#","$","%","_","/",",",".",":","\""]
        var string2 = word
        var finalString2 = ""
        for char in string2 {
            if !specialChar.contains(String(char)) {
                finalString2.append(char)
            }
        }
        string2 = finalString2
        //print(string2)
        return string2
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                // if start.text has been loaded then we want its 10.000 words be split up in an array of strings w linebreaks
                let allWords = startWords.components(separatedBy: "\n")
                // grab one to use in-Game - in case it fails ?? nil-coalescing provides default
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
    fatalError("Could not load start.text from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        
    }
    
    
} // ContentView


// MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
