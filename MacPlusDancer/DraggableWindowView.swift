//
//  DraggableWindowView.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import SwiftUI
import AppKit

class CustomWindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldMove(_ window: NSWindow) -> Bool {
        return true
    }
}

class DraggableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    override func mouseDragged(with event: NSEvent) {
        self.performDrag(with: event)
    }
}

struct DraggableWindowView: NSViewRepresentable {
    let windowDelegate = CustomWindowDelegate()

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                let draggableWindow = DraggableWindow(contentRect: window.frame,
                                                      styleMask: [.borderless, .fullSizeContentView],
                                                      backing: .buffered,
                                                      defer: false)
                draggableWindow.contentView = window.contentView
                draggableWindow.delegate = self.windowDelegate
                draggableWindow.isMovableByWindowBackground = true
                draggableWindow.makeKey()
                window.close()
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
