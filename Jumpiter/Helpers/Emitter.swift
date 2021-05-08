//
//  Emitter.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 5/8/21.
//

import Foundation
import SpriteKit

protocol Emitter: AnyObject, PhysicsManager {
  var emitterName: String { get }
  func emit(node: SKNode?, color: NSColor, offset: CGPoint)
}

extension Emitter {
  
  func emit(node: SKNode?, color: NSColor, offset: CGPoint = .zero) {
    guard let node = node else {
       return
    }
    
    if let particles = SKEmitterNode(fileNamed: emitterName) {
      let position = CGPoint(x: node.position.x + offset.x, y: node.position.y + offset.y)
      particles.position = position
      node.addChild(particles)
      particles.targetNode = node.scene
      particles.particleColor = color
    }
  }
  
}
