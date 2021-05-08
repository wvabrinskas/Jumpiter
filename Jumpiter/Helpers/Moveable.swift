//
//  Moveable.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 5/8/21.
//

import Foundation
import SpriteKit

public protocol Moveable {
  var moveableNode: SKNode? { get }
  var minX: CGFloat? { get set }
  var actionName: String { get set }
  func shouldRemove() -> Bool
  func move()
}

extension Moveable {
  
  public func shouldRemove() -> Bool {
    guard let min = minX, let node = self.moveableNode else {
      return true
    }
    return (node.position.x + node.frame.size.width) < min
  }
  
  public func move() {
    if let action = SKAction(named: actionName) {
      moveableNode?.run(action)
    }
  }
}
