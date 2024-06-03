import SwiftUI
import WebKit
import ColumnTaxFile

let defaultUserUrl = "<user url>"

struct ContentView: View {
    @State private var inputText: String = ""
    
    @State private var TestInputText: String = ""

    @State var activeWebView = false

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)).edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 20) {
                Text("CT iOS Tester")
                    .foregroundColor(.white)
                    .font(.title)

                // Single-line text input to paste the Column Tax URL
                TextField("Paste Column Tax URL here", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Button to open the specified URL in a webview
                Button(action: {
                    self.activeWebView = true
                }) {
                    Text("Open Column")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding()
                        .border(Color(.white), width: 5)
                }.sheet(isPresented: $activeWebView, content: {
                    // open the Column Tax SDK!
                    ColumnTaxFile(
                        userUrl: URL(string: getUrlText())!,
                        isPresented: self.$activeWebView,
                        handleClose: self.handleClose
                    ).edgesIgnoringSafeArea(.all)
                })
            }
        }
    }
    
    // handles a close event sent from webview
    func handleClose() {
        activeWebView = false
    }

    func getUrlText() -> String {
        if (self.inputText.isEmpty) {
            return defaultUserUrl;
        } else {
            return self.inputText;
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
