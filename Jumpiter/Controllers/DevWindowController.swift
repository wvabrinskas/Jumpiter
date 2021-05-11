//
//  DevViewController.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 5/10/21.
//

import Foundation
import Cocoa

class DevWindowController: NSWindowController {
  init(frame: NSRect) {
      
    let newWindow = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 300,
                                                                            height: 600)),
                             styleMask: [.closable, .resizable, .miniaturizable, .titled],
                              backing: .buffered,
                              defer: true)
    newWindow.title = "Stats"
    newWindow.center()
    super.init(window: newWindow)
    self.window = newWindow
  }
  
  func setStats<T>(_ stats: [Stat<T>]) {
    if let cont = self.contentViewController as? DevViewController<T> {
      cont.update(stats)
    } else {
      let cont = DevViewController<T>()
      cont.update(stats)
      self.contentViewController = cont
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  public func show() {
    self.showWindow(self)
  }
}
