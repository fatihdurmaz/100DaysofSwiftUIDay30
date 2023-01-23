//
//  ContentView.swift
//  SwiftUIDay30
//
//  Created by Fatih Durmaz on 23.01.2023.
//

import SwiftUI

struct ContentView: View {
    @State var kelimeler = [String]()
    @State var kokKelime = ""
    @State var girilenKelime = ""
    var body: some View {
        NavigationStack{
            List{
                Section {
                    TextField("kelime giriniz", text: $girilenKelime)
                        .textInputAutocapitalization(.never)
                }
                
                Section ("Kelimeler") {
                    ForEach(kelimeler, id:\.self){ kelime in
                        HStack {
                            Image(systemName: "\(kelime.count).circle")
                            Text(kelime).bold().italic()
                        }
                    }
                }
            }
            .navigationTitle(kokKelime)
            .onSubmit(kelimeEkle)
            .onAppear(perform: startGame)
        }
    }
    
    func kelimeEkle() {
        let eklenecekKelime = girilenKelime.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard eklenecekKelime.count > 0 else {
            return // boş geçilmesini engelliyoruz
            // guard geriye boş return döndürmek zorundadır.
        }
        withAnimation {
            kelimeler.insert(eklenecekKelime, at: 0)
            // append() kullanmadık çünkü dizinin souna ekler yeni elemanı. insert ile hangi sıraya (indise) ekleneceğini belirtebiliriz.
        }
        girilenKelime = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                kokKelime = allWords.randomElement() ?? "elektrik"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
