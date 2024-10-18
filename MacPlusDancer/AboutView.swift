//
//  AboutView.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import SwiftUI

struct AboutView: View {
    struct FAQItem {
        let question: String
        let answer: AttributedString
        
        init(question: String, answer: String) {
            self.question = question
            self.answer = try! AttributedString(markdown: answer, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        }
    }
    
    let faqItems: [FAQItem] = [
        FAQItem(question: "What the hell is this?",
                answer: "Thank you for asking. This is a deeply unofficial Mac port of the [Dancers from the Microsoft Plus bundle (2003)](https://hachyderm.io/@samhenrigold/113307328021293777).\n\nThey're a bunch of tiny divas that just dance around wherever you drag them. Stick 'em on top of your Google Docs. Make them poke out from behind TurboTax. Do whatever you want."),
        FAQItem(question: "Why should I use this?",
                answer: "You should not."),
        FAQItem(question: "Why can't I make Seth stop dancing?",
                answer: "I cannot legally answer that."),
        FAQItem(question: "Why is this app so big?",
                answer: "This app is 52 video files in a trench coat.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(faqItems, id: \.question) { item in
                    FAQView(item: item)
                }
                Spacer()
                    .frame(height: 16)
                
                FooterView()
            }
            .padding(.top, 32)
            .padding(.horizontal, 48)
        }
        .frame(maxWidth: 480)
    }
}

struct FAQView: View {
    let item: AboutView.FAQItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.question)
                .font(.title3)
                .bold()
            Text(item.answer)
        }
    }
}

struct FooterView: View {
    var body: some View {
        Text("Made with \(Image(systemName: "heart.fill")) by [Sam Henri Gold](https://hachyderm.io/@samhenrigold/)")
            .frame(maxWidth: .infinity)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    AboutView()
}
