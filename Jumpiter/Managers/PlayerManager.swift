//
//  PhysicsManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit
import GameplayKit

public class PlayerManager: PhysicsManager,
                            SpriteBuilder,
                            Emitter {

  var storedParticles: SKEmitterNode?
  public var player: SKSpriteNode = SKSpriteNode()
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
  public var wallet: Float = 0
  public var color: NSColor = .white
  public var numOfJumps: Int = 0
  public var lastCollectedCoinId: UUID?
  public var spriteFrames: [SKTexture] = []
  var emitterName: String {
   return "magic.sks"
  }
  
  public init() {
    self.player = self.buildSprite(atlas: "player", texturePrefix: "player_")
    self.player.setScale(0.4)
    
    let size = CGSize(width: player.frame.size.width * 0.8,
                      height: player.frame.size.height * 0.88)
    
    self.addPhysics(to: player, size: size, mass: 1, restitution: 0.0)
    self.player.physicsBody?.categoryBitMask = 0b0010
    self.player.physicsBody?.collisionBitMask = 0b0001
    self.player.physicsBody?.contactTestBitMask = ContactBitMasks.player.rawValue
    self.color = NSColor.init(red: CGFloat.random(in: 0...1),
                              green: CGFloat.random(in: 0...1),
                              blue: CGFloat.random(in: 0...1),
                              alpha: 1.0)
  }
  
  public func setOff(off: Bool) {
    self.player.isHidden = !off
    self.player.isPaused = !off
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
    self.animateSprite(self.player)
    let offset = CGPoint(x: 100, y: -60)
    self.emit(node: self.player, color: self.color, offset: offset)
  }
  
  public func updateCoin(_ value: Float, _ id: UUID) {
    guard id != self.lastCollectedCoinId else {
      return
    }
    self.lastCollectedCoinId = id
    wallet += value
    GameState.shared.setHighestWallet(wallet: wallet)
  }
  
  public func update() {
    score += 1
    GameState.shared.setHighestScore(score: score)
  }
  
  public func reset() {
    wallet = 0
    score = 0
    isDead = false
    numOfJumps = 0
  }
}
