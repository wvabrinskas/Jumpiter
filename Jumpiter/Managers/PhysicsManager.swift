//
//  PhysicsManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit

public enum ForceVector {
  case up, down, left, right
}

protocol PhysicsManager {
  func addPhysics(to: SKNode?,
                  dynamic: Bool,
                  mass: CGFloat,
                  allowRotation: Bool,
                  restitution: CGFloat)
  func startPhysics(world: SKPhysicsWorld, gravity: CGFloat)
  func applyForce(force: CGFloat,
                  direction: ForceVector,
                  to: SKNode?)
}

extension PhysicsManager {
  func setDynamic(to: SKNode?, dynamic: Bool) {
    guard let node = to, node.physicsBody != nil else {
      return
    }
  }
  
  func addPhysics(to: SKNode?,
                  dynamic: Bool = true,
                  mass: CGFloat = 10,
                  allowRotation: Bool = false,
                  restitution: CGFloat = 0.0) {
    guard let node = to, node.physicsBody == nil else {
      return
    }
    
    node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
    node.physicsBody?.isDynamic = dynamic
    node.physicsBody?.mass = mass
    node.physicsBody?.allowsRotation = allowRotation
    node.physicsBody?.restitution = restitution
  }
  
  func startPhysics(world: SKPhysicsWorld, gravity: CGFloat = -9.82) {
    world.gravity = CGVector(dx: 0, dy: gravity)
  }
  
  func applyForce(force: CGFloat, direction: ForceVector, to: SKNode?) {
    let force = abs(force)
    
    guard let node = to, node.physicsBody != nil else {
      return
    }
    var vector: CGVector = .zero
    
    switch direction {
    case .up:
      vector = CGVector(dx: 0, dy: force)
    case .down:
      vector = CGVector(dx: 0, dy: -force)
    case .right:
      vector = CGVector(dx: force, dy: 0)
    case .left:
      vector = CGVector(dx: -force, dy: 0)
    }
    
    node.physicsBody?.applyImpulse(vector)
  }
}
