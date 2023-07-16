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
    @State private var rootWordPresented = ""
    // hint in textField
    @State private var hintTextField = ""
    // new attempt by player to bind to textfield
    @State private var newWord = ""
    
    // if array has an even number of indexes set to true
    private var even : Bool {
        return usedWords.count % 2 == 0
    }
    
    // data for Alert Message
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var warningMessage = ""
    
    //data for keeping Score
    @State private var wordStreak : Int = 0
    @State private var score : Int = 0
    @State private var highScore : Int = 0
    @State private var longestStreak : Int = 0

    @State private var scoreBoard = ""
    
    
    // MARK: - body VIEW
    
        var body: some View {

            NavigationStack {
                ZStack {
                    List {
                        Section {
                            Text(scoreBoard)
                            Text("word streak:                 \(wordStreak)")
                            Text("score:                            \(score)")
                        } .font(.subheadline)
                        
                        Section {
                            Button("\(rootWordPresented)", action: {
                                startGame()
                            })
                            
                                .font(.largeTitle)
                            TextField(hintTextField, text: $newWord)
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
                      // .navigationTitle(rootWord)
                    .onSubmit(addNewWord)
                    .onAppear(perform: startGame)
                    
                    .alert(errorTitle, isPresented: $showingError) {
                        Button("Ok", role: .cancel) { deleteLetters() }
                    } message: {
                        Text(errorMessage)
                    }
                    
                } // end ZStack
        } // end NavStack
      
   
        
    } //end body View
    
    /* *********************************************************************************/
    /*                                                                                 */
    // MARK: - METHODS                                                                 //
    /*                                                                                 */
    /* *********************************************************************************/

    
    func startGame() {
        score = 0
        wordStreak = 0
        usedWords = []
        
        scoreBoard = "HighScore:    \(highScore)     -    longest word streak: \(longestStreak)"
        
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                // if start.text has been loaded then we want its 10.000 words be split up in an array of strings w linebreaks
                let allWords = startWords.components(separatedBy: "\n")
                // grab one to use in-Game - in case it fails ?? nil-coalescing provides default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                presentRootwordAnimated(word: rootWord)
                presentCommentAnimated()
                return
            }
        }
        
    fatalError("Could not load start.text from bundle.")
    }
    
    
    func addNewWord() {
        if warningMessage != "" {
            warningMessage = ""
        }
    
    // Check 1 of the TextField entry > lowerCase > no whiteSpace
        let answer = newWord.lowercased().trimmingCharacters(in:  .whitespaces)
        //  Check 2 no separate words
        let answer2 = specificCharDeletion(word: answer)
        
        // make sure theres a minimum requirement
        guard answer2.count > 0 else { return }
        
        // insert more methods to check on word here
        guard copyCat(word: answer2) else {
            wordError(title: "copycat !", message: "we will let this one slide", warning: "copyCat")
            return
        }
        
        guard isOriginal(word: answer2) else {
            wordError(title: "Word used already", message: "make each attempt unique", warning: "repeat")
            return
        }
        
        guard isPossible(word: answer2) else {
            wordError(title: "Letters not found", message: "you can't spell '\(answer2)' from the letters of '\(rootWord)'", warning: "wrongLetter")
            return
        }
        
        guard isReal(word: answer2) else {
            wordError(title: "Word not recognised by Dictionary", message: "Making up words not allowed in this game: try Scrabble instead", warning: "madeUpWord")
            return
        }
        // add answer to array at 0 so it comes in at the top of the List always in view
        presentCommentAnimated()
        
        withAnimation {
            usedWords.insert(answer2, at: 0)
            wordStreak += 1
            score += answer2.count
        }
        
        checkHighScoreStreak()
        
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
    
    func copyCat(word: String) -> Bool {
        
        if word == rootWord {
         
            return false
        } else {
            return true
            
        }
    }
    
    func isOriginal(word: String) -> Bool {
        // if NOT in usedWords collection THEN true means word is original
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        // check letter by letter player entry
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        // if all letters check out ok then isPossible is true
        return true
    }
    
    // create NSRange UTF16 via UIKit to check for misspelled words.
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }

    // errorMessage Alert pop up
    func wordError(title: String, message: String, warning: String) {
        errorTitle = title
        errorMessage = message
        warningMessage = warning
        showingError = true
    }
    
    // delete newWord one letter at a time ?
    func deleteLetters() {
        let waitForDeleteLetters = 0.1 * Double(newWord.count)
        
        for i in 0...newWord.count {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)) {
                withAnimation {
                    let newerWord = newWord
                    newWord =  String(newerWord.dropLast())
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.1 * Double(newWord.count) * waitForDeleteLetters)) {
            presentCommentAnimated()
        }
    }
    
    func presentRootwordAnimated(word:String) {
        let wordToBePresented = Array(word)
        var buildingWord = ""
        
        
        for i in 0..<word.count {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * Double(i)) {
                withAnimation {
                    buildingWord.append(wordToBePresented[i])
                    rootWordPresented = buildingWord
                }
            }
        }
    }
    
    func presentCommentAnimated() {
        let defaultHint = "create new words from letters of ⬆"
        var hintToBePresented = Array(defaultHint)
        var scoreComment = ""
        let defaultComment = "\(newWord.count) points : \(scoreComment)"
        var buildingHint = ""
        var buildingComment = ""
        var warningComment = warningMessage
        var buildingWarning = ""
        
        if warningComment != "" {
            let repeatOffender = ["you tried that one already", "repeat offender", "try harder", "each entry must be original", "not that one again"]
            let letterOffender = ["you can't use the letters not in the rootWord", "stick to the letters in the word above", "dont use letters not in the word"]
            let fantasist = ["dude..", "if its not in the dictionary ..", "maybe you've heard of that word but UIKit hasn't", "is that slang ?", "I'm sorry but that word does not exist", "does that word even exist ?", "you're on your own here", "uhm.. no", "is that Dutch ?", "is that Tagalog ?", "Maybe in your language but in english.."]
            let cheater = ["that's .. lazy", "cheaters never prosper", "I tried that once .. now I'm a bot", "first time here ?", "you cannot copy the root word", "player is the 2.394.862th person to try that", "easy pickings ? THINK AGAIN"]
            
            switch warningComment {
            case "repeat" :
                warningComment = repeatOffender.randomElement() ?? "you tried"
                hintToBePresented = Array(warningComment)
            case "wrongLetter" :
                warningComment = letterOffender.randomElement() ?? "bad letter"
                hintToBePresented = Array(warningComment)
            case "madeUpWord" :
                warningComment = fantasist.randomElement() ?? "404 - word not found"
                hintToBePresented = Array(warningComment)
            case "copyCat" :
                warningComment = cheater.randomElement() ?? "505 - cheat not found"
                hintToBePresented = Array(warningComment)
                
            default:
                warningComment = "last chance"
            }
            for i in 0..<warningComment.count {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i)) {
                    withAnimation {
                        buildingWarning.append(hintToBePresented[i])
                        hintTextField = buildingWarning
                    }
                }
            }
        }
        else if wordStreak == 0 {
            var hintToBePresented = Array(defaultHint)
            
            for i in 0..<defaultHint.count {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i)) {
                    withAnimation {
                        buildingHint.append(hintToBePresented[i])
                        hintTextField = buildingHint
                    }
                }
            }
            
        } else {
            
            let threePoints = ["low hanging fruit", "easy pickings", "lucky !", "oof", "where did you see that one ?", "woohoo", "3 pointer !"]
            let fourPoints = ["cool !", "okay..", "nice one", "didnt see that one !", "4 points", "yes !", "crazy..", "getting harder", "meh", "you can do better"]
            // present comment about last word entered
            switch newWord.count {
            case 1...3 : scoreComment = threePoints.randomElement() ?? "you got points"
                hintToBePresented = Array(scoreComment)
            case 4 : scoreComment = fourPoints.randomElement() ?? "you score 4 points"
                hintToBePresented = Array(scoreComment)
            case 5 : scoreComment = "5 points ?!"
                hintToBePresented = Array(scoreComment)
            case 6 : scoreComment = "wowzer"
                hintToBePresented = Array(scoreComment)
            case 7 : scoreComment = "GREAT !"
                hintToBePresented = Array(scoreComment)
            case 8 : scoreComment = "EXCELLENT !"
                hintToBePresented = Array(scoreComment)
                
            default : scoreComment = "try again !"
            }
            for i in 0..<scoreComment.count {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i)) {
                    withAnimation {
                        buildingComment.append(hintToBePresented[i])
                        hintTextField = buildingComment
                    }
                }
            }
            
        }
        
    }
    
    func checkHighScoreStreak() {
        var update = false
        var buildingBoard = ""
        
        if score > highScore {
            highScore = score
            update = true
        }
        
        if wordStreak > longestStreak {
                longestStreak = wordStreak
            update = true
        }
        
       let scoreBoardPresented = Array("HighScore:    \(highScore)     -    longest word streak: \(longestStreak)")

        if update {
            for i in 0..<scoreBoardPresented.count {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(i)) {
                    withAnimation {
                        buildingBoard.append(scoreBoardPresented[i])
                        scoreBoard = buildingBoard
                    }
                    
                }
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
