//
//  ContentView.swift
//  WordScramble
//
//  Created by sanmi_personal on 12/04/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showingError = false
    
    @State private var userScore = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Restart") {
                        startGame()
                        usedWords.removeAll()
                        newWord = ""
                        userScore = 0
                    }.padding()
                    
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                }
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("user score \(userScore)")
            }
            .navigationTitle(rootWord)
            .onAppear(perform: {
                startGame()
            })
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0  else {
            return
        }
        
        guard isWordTooShort(word: answer) else {
            wordError(title: "Word is too short", message: "You can't add a word with less than three characters")
            return
        }
        guard isNotRootWord(word: answer) else {
            wordError(title: "Word is should not be the same as the root word", message: "Nice try! The root word doesn't count")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up, you know")
            return
        }
        guard isRealWord(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real world")
            return
        }
        
        userScore += answer.count
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "SilkWord"
                return
            }
            
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isWordTooShort(word: String) -> Bool {
        return word.count > 3
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isNotRootWord(word: String) -> Bool {
        rootWord.lowercased() != word.lowercased()
    }
    
    func isRealWord(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledWord = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledWord.location == NSNotFound
    }
    
    func wordError(title: String, message: String)  {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
