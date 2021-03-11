//
//  PhysicsManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit
import GameplayKit

public class PlayerManager: PhysicsManager {
  public var player: SKShapeNode
  public var isDead: Bool = false {
    didSet {
      if isDead {
        DispatchQueue.main.async {
          self.player.removeFromParent()
        }
      }
    }
  }
  public var score: Int = 0
  public var color: NSColor = .white
  
  public init() {
    self.player = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 15)
    self.player.fillColor = self.randomColor()
    self.color = self.player.fillColor
    self.player.strokeColor = .clear
    
    self.addPhysics(to: player, mass: 1, restitution: 0.0)
    self.player.physicsBody?.categoryBitMask = 0x00000001
    self.player.physicsBody?.collisionBitMask = 0x00000010
  }
  
  private func randomColor() -> NSColor {
    let r = CGFloat.random(in: 0...1)
    let g = CGFloat.random(in: 0...1)
    let b = CGFloat.random(in: 0...1)
    
    return NSColor(red: r, green: g, blue: b, alpha: 0.6)
  }
  
  public func jump() {
    self.applyForce(force: 1700, direction: .up, to: self.player)
  }
  
  public func setup(in scene: SKScene?) {
    scene?.addChild(player)
    
    if let scene = scene {
      player.position = CGPoint(x: scene.frame.minX * 0.3, y: 0)
    }
  }
  
  public func updateScore() {
    score += 1
  }
  
  public func resetScore() {
    score = 0
  }
}
