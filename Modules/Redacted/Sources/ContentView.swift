import RedactedCore
import SwiftUI

struct ContentView: View {
    // MARK: - View
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Text("Version \(RedactedCore.version)")
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                Button(action: newImage) {
                    Image(systemName: "plus.square")
                }

                Button(action: openImage) {
                    Image(systemName: "folder")
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Private
    
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
            .automatic
        #else
            .bottomBar
        #endif
    }
    
    private func newImage() {}
    private func openImage() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
