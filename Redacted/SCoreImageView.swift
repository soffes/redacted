import AppKit
import CoreImageView
import SwiftUI

struct SCoreImageView: NSViewRepresentable {
    var ciImage: CIImage?

    func makeNSView(context: Context) -> CoreImageView {
        CoreImageView()
    }

    func updateNSView(_ view: CoreImageView, context: Context) {
        view.ciImage = context.coordinator.ciImage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var ciImage: CIImage?

        init(_ parent: SCoreImageView) {
            self.ciImage = parent.ciImage
        }
    }
}
