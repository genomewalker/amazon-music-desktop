import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let backgroundRect = NSRect(origin: .zero, size: size)
let gradient = NSGradient(colors: [
    NSColor(red: 0.13, green: 0.17, blue: 0.32, alpha: 1.0),
    NSColor(red: 0.36, green: 0.18, blue: 0.55, alpha: 1.0)
])
gradient?.draw(in: backgroundRect, angle: 35)

let symbolConfig = NSImage.SymbolConfiguration(pointSize: 540, weight: .bold)
if let symbol = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil) {
    let configured = symbol.withSymbolConfiguration(symbolConfig)
    configured?.isTemplate = true
    let symbolSize = NSSize(width: 540, height: 540)
    let symbolRect = NSRect(
        x: (size.width - symbolSize.width) / 2,
        y: (size.height - symbolSize.height) / 2,
        width: symbolSize.width,
        height: symbolSize.height
    )
    NSColor.white.set()
    configured?.draw(in: symbolRect)
}

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to generate PNG")
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "AppIcon.png")
try pngData.write(to: outputURL)
print("Icon written to: \(outputURL.path)")
