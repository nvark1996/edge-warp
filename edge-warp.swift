// edge-warp — lets the pointer cross between side-by-side screens of different heights.
// macOS only lets the pointer pass where two screens' edges overlap; pushing left/right
// against a screen edge outside that overlap normally hits a wall. When that happens and a
// screen sits beyond that edge, warp the pointer onto it (height clamped to that screen).
// LaunchAgent local.edge-warp. Listen-only event tap; never alters the events themselves.
import CoreGraphics
import Foundation

func activeBounds() -> [CGRect] {
    var ids = [CGDirectDisplayID](repeating: 0, count: 16); var n: UInt32 = 0
    CGGetActiveDisplayList(16, &ids, &n)
    return ids.prefix(Int(n)).map { CGDisplayBounds($0) }
}

func handle(_ e: CGEvent) {
    let dx = e.getDoubleValueField(.mouseEventDeltaX)
    guard dx != 0 else { return }
    let p = e.location
    let screens = activeBounds()
    guard let cur = screens.first(where: { $0.contains(p) }) else { return }
    let atLeft = dx < 0 && p.x < cur.minX + 1, atRight = dx > 0 && p.x > cur.maxX - 2
    guard atLeft || atRight else { return }
    // Neighbour touching this edge whose vertical span does not include the pointer.
    guard let nb = screens.first(where: { s in
        s != cur && (atLeft ? abs(s.maxX - cur.minX) < 1 : abs(s.minX - cur.maxX) < 1)
            && s.maxY > cur.minY && s.minY < cur.maxY && !(p.y >= s.minY && p.y < s.maxY)
    }) else { return }
    let to = CGPoint(x: atLeft ? nb.maxX - 2 : nb.minX + 1, y: min(max(p.y, nb.minY), nb.maxY - 1))
    CGWarpMouseCursorPosition(to)
    FileHandle.standardError.write("warp \(Int(p.x)),\(Int(p.y)) -> \(Int(to.x)),\(Int(to.y))\n".data(using: .utf8)!)
    CGAssociateMouseAndMouseCursorPosition(1)   // no post-warp freeze
}

let mask: CGEventMask = [CGEventType.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
    .reduce(0) { $0 | (1 << $1.rawValue) }
var tapRef: CFMachPort?
guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .tailAppendEventTap, options: .listenOnly,
                                  eventsOfInterest: mask, callback: { _, type, e, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput { if let t = tapRef { CGEvent.tapEnable(tap: t, enable: true) } }
    else { handle(e) }
    return Unmanaged.passUnretained(e)
}, userInfo: nil) else {
    FileHandle.standardError.write("edge-warp: could not create event tap\n".data(using: .utf8)!); exit(1)
}
tapRef = tap
CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
FileHandle.standardError.write("\(ISO8601DateFormatter().string(from: Date())) edge-warp started\n".data(using: .utf8)!)
CFRunLoopRun()
