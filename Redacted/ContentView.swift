import AppKit
import SwiftUI
import Vision

struct ContentView: View {

    // MARK: - Types

    struct Annotation: Identifiable {
        var id = UUID()
        var frame: CGRect
        var rotation: Double
        var color: Color

        init(boundingBox: CGRect, rotation: Double, color: Color) {
            frame = CGRect(x: boundingBox.origin.x, y: boundingBox.height - boundingBox.origin.y,
                           width: boundingBox.width, height: boundingBox.height)
            self.rotation = rotation
            self.color = color
        }
    }

    // MARK: - Properties

    @State
    private var annotations = [Annotation]()

    private let cgImage = NSImage(named: "test")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!

    // MARK: - View

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SCoreImageView(ciImage: CIImage(cgImage: cgImage))

                ForEach(annotations) { annotation in
                    let frame = annotation.frame.applying(CGAffineTransform(scaleX: geometry.size.width, y: geometry.size.height))

                    Rectangle()
                        .fill(.clear)
                        .border(annotation.color, width: 2)
                        .frame(width: frame.width, height: frame.height)
                        .rotationEffect(.radians(-annotation.rotation))
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }.onAppear {
            detect(in: cgImage)
        }
    }

    // MARK: - Private

    // See https://developer.apple.com/documentation/vision/detecting_objects_in_still_images
    private func detect(in cgImage: CGImage) {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let barcodes = VNDetectBarcodesRequest(completionHandler: detectBarcodes)
        let faces = VNDetectFaceRectanglesRequest(completionHandler: detectFaces)
        let text = VNDetectTextRectanglesRequest(completionHandler: detectText)

        print("identifiers: \(try! VNRecognizeAnimalsRequest(completionHandler: detectBarcodes).supportedIdentifiers())")

        do {
            try handler.perform([
                barcodes,
                faces,
                text
            ])
        } catch {
            print("error: \(error)")
        }
    }

    private func detectBarcodes(request: VNRequest, error: Error?) {
        if let error = error {
            print("Barcodes error: \(error)")
            return
        }

        guard let results = (request as? VNDetectBarcodesRequest)?.results else {
            return
        }

        for result in results {
            print("Barcode: \(result)")
        }
    }

    private func detectFaces(request: VNRequest, error: Error?) {
        if let error = error {
            print("Faces error: \(error)")
            return
        }

        guard let results = (request as? VNDetectFaceRectanglesRequest)?.results else {
            return
        }

        annotations += results.map { Annotation(boundingBox: $0.boundingBox, rotation: $0.roll?.doubleValue ?? 0, color: .blue) }
    }

    private func detectText(request: VNRequest, error: Error?) {
        if let error = error {
            print("Text error: \(error)")
            return
        }

        guard let results = (request as? VNDetectTextRectanglesRequest)?.results else {
            return
        }

        annotations += results.map { Annotation(boundingBox: $0.boundingBox, rotation: 0, color: .red) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
