//
//  ContentView.swift
//  SwiftUIDay30
//
//  Created by Fatih Durmaz on 23.01.2023.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    @State var kelimeler = [String]()
    @State var kokKelime = ""
    @State var girilenKelime = ""
    @State private var hataBaslik = ""
    @State private var hataMesaj = ""
    @State private var hataGoster = false
    
    var body: some View {
        NavigationView{
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
            .onAppear(perform: oyunuBaslat)
            .toast(isPresenting: $hataGoster){
                AlertToast(type: .error(.red), title: hataBaslik, subTitle: hataMesaj)
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button("Yeni Kelime") {
                        restart()
                    }
                }
            }
        }
        
    }
    
    func kelimeEkle() {
        let kelime = girilenKelime.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard kelime.count > 1 else {
            return // boş geçilmesini engelliyoruz
            // guard geriye boş return döndürmek zorundadır.
        }
        
        guard isOriginal(word: kelime) else {
            wordError(baslik: "Aynı Kelime", mesaj: "Daha önce bu kelimeyi kullandınız.")
            return
        }
        
        guard isPossible(word: kelime) else {
            wordError(baslik: "Olmayan Harf", mesaj: "Kelimede olmayan harfleri kullandınız.")
            return
        }
        
        guard isReal(word: kelime) else {
            wordError(baslik: "Geçersiz Kelime", mesaj: "Geçerli bir kelime girmediniz.")
            return
        }
        
        withAnimation {
            kelimeler.insert(kelime, at: 0)
            // append() kullanmadık çünkü dizinin souna ekler yeni elemanı. insert ile hangi sıraya (indise) ekleneceğini belirtebiliriz.
        }
        girilenKelime = ""
    }
    
    func oyunuBaslat() {
        // 1. start.txt dosyasını tanımlıyoruz.
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. dosya içeriğini string olacak şekilde bir değişkene atıyoruz.
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. değişkene attığımız içeriğin her bir satırındaki değeri, \n (alt satıra geçme) karakterine göre dizi değişkenine atıyoruz.
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. dizi içerisinden rastgele bir değer seçip kokKelime değişkenine atıyoruz.
                kokKelime = allWords.randomElement()?.lowercased() ?? "elektrik"
                
                return
            }
        }
        
        // yukarıdaki işlemlerden herhangi birinde hata almışsak geriye hata mesajı gönderiyoruz.
        // fatalError() : İşlemi durdurup hata mesajı fırlatma hazır fonksiyonudur.
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !kelimeler.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = kokKelime
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "tr")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(baslik: String, mesaj: String ) {
        hataBaslik = baslik
        hataMesaj = mesaj
        hataGoster = true
    }
    
    func restart() {
        kelimeler.removeAll()
        oyunuBaslat()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
