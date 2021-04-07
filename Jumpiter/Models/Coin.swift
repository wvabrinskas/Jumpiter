//
//  Coin.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 4/2/21.
//

import Foundation
import SpriteKit

public struct CoinMaker {
  var value: Int = 5
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
  
  public var collected: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.coin.removeFromParent()
      }
    }
  }
  
  public var id: UUID = UUID()
  public var value: Int
  public var coin: SKSpriteNode = SKSpriteNode()
  public var position: CGPoint
  private var minX: CGFloat?

  public static func == (lhs: Coin, rhs: Coin) -> Bool {
    lhs.id == rhs.id
  }
  
  public init(maker: CoinMaker, scene: SKScene) {
    minX = -scene.frame.width

    self.value = maker.value
    self.position = maker.pos
    self.buildCoin()
  }
  
  private func buildCoin() {
    self.coin = self.buildSprite(atlas: "coin", texturePrefix: "coin_")
    self.coin.position = self.position
    self.addPhysics(to: coin, dynamic: false)
    self.animateSprite(coin)
  }
  
  public func gotCoin() {
    self.coin.removeFromParent()
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
  
  public func removePhysics() {
    self.coin.isHidden = true
    self.coin.physicsBody?.categoryBitMask = 0x00000001
    self.coin.physicsBody?.collisionBitMask = 0x00000010
  }
  
}
