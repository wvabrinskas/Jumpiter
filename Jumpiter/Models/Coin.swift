//
//  Coin.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 4/2/21.
//

import Foundation
import SpriteKit

public struct CoinMaker {
  var value: Float = 1.0
  var pos: CGPoint
}

public class Coin: SpriteBuilder,
                   HitTester,
                   PhysicsManager,
                   Equatable {

  var hitTestObject: SKNode {
    return coin
  }
  internal var spriteFrames: [SKTexture] = []
  
  private var collected: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.coin.physicsBody = nil
        self.coin.removeFromParent()
      }
    }
  }
  
  public var id: UUID = UUID()
  public var value: Float
  public var coin: SKSpriteNode = SKSpriteNode()
  public var position: CGPoint
  private var minX: CGFloat?

  public static func == (lhs: Coin, rhs: Coin) -> Bool {
    lhs.id == rhs.id
  }
  
  public init(maker: CoinMaker, scene: SKScene) {
    minX = scene.frame.minX

    self.value = maker.value
    self.position = maker.pos
    self.buildCoin()
  }
  
  private func buildCoin() {
    self.coin = self.buildSprite(atlas: "coin", texturePrefix: "coin_")
    self.coin.position = self.position
    self.addPhysics(to: coin, size: coin.frame.size, dynamic: false)
    self.coin.physicsBody?.collisionBitMask = 0b0001
    self.coin.physicsBody?.categoryBitMask = 0b0100
    self.coin.physicsBody?.contactTestBitMask = ContactBitMasks.coin.rawValue

    self.animateSprite(coin)
  }
  
  public func gotCoin() {
    self.collected = true
  }
  
  public func move() {
    if let action = SKAction(named: "move") {
      coin.run(action)
    }
  }
  
  public func shouldRemove() -> Bool {
    guard let min = minX else {
      return true
    }
    return (coin.position.x + coin.frame.size.width) < min
  }
  
  //dirty hack to remove coin from UI but not from the scene
  //will be removed when it goes off screen
  public func removePhysics() {
    self.coin.isHidden = true
  }
  
}
