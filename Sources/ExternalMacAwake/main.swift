import Foundation

// `--render-preview <dir>` renders the popover to PNGs offscreen and exits.
let arguments = CommandLine.arguments
if let flag = arguments.firstIndex(of: "--render-preview") {
    guard arguments.indices.contains(flag + 1) else {
        FileHandle.standardError.write(Data("usage: ExternalMacAwake --render-preview <dir>\n".utf8))
        exit(64)
    }
    exit(PreviewRenderer.run(outputDirectory: URL(fileURLWithPath: arguments[flag + 1])))
} else {
    ExternalMacAwakeApp.main()
}
