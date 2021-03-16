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
  public var player: SKSpriteNode
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
  public var numOfJumps: Int = 0
  private var playerFrames: [SKTexture] = []

  public init() {
    let bearAnimatedAtlas = SKTextureAtlas(named: "player")
    var walkFrames: [SKTexture] = []

    let numImages = bearAnimatedAtlas.textureNames.count
    for i in 1...numImages {
      let bearTextureName = "player_\(i)"
      walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
    }
    
    self.playerFrames = walkFrames
    
    let firstFrameTexture = playerFrames[0]
    self.player = SKSpriteNode(texture: firstFrameTexture)
    
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
    numOfJumps += 1
    self.applyForce(force: 1700, direction: .up, to: self.player)
  }
  
  public func setup(in scene: SKScene?) {
    scene?.addChild(player)
    
    player.position = CGPoint(x: GameState.shared.playerStartPosition , y: 0)
  }
  
  public func updateScore() {
    score += 1
    GameState.shared.setHighestScore(score: score)
  }
  
  public func reset() {
    score = 0
    isDead = false
    numOfJumps = 0
  }
}
