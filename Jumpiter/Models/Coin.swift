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

public class Coin: NodeHolder,
                   HitTester,
                   SpriteBuilder,
                   PhysicsManager {
  
  public var moveableNode: SKNode?
  public var minX: CGFloat?
  public var actionName: String = "move"
  var hitTestObject: SKNode {
    return node
  }
  public var spriteFrames: [SKTexture] = []
  
  private var collected: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.node.physicsBody = nil
        self.node.removeFromParent()
      }
    }
  }
  
  public var id: UUID = UUID()
  public var value: Float
  public var node: SKSpriteNode = SKSpriteNode()
  public var position: CGPoint

  public static func == (lhs: Coin, rhs: Coin) -> Bool {
    lhs.id == rhs.id
  }
  
  public init(maker: CoinMaker, scene: SKScene) {
    minX = scene.frame.minX

    self.value = maker.value
    self.position = maker.pos
    self.buildCoin()
    self.moveableNode = self.node
  }
  
  private func buildCoin() {
    self.node = self.buildSprite(atlas: "coin", texturePrefix: "coin_")
    self.node.position = self.position
    self.addPhysics(to: node, size: node.frame.size, dynamic: false)
    self.node.physicsBody?.collisionBitMask = 0b0001
    self.node.physicsBody?.categoryBitMask = 0b0100
    self.node.physicsBody?.contactTestBitMask = ContactBitMasks.coin.rawValue

    self.animateSprite(node)
  }
  
  public func gotCoin() {
    self.collected = true
  }

  //dirty hack to remove coin from UI but not from the scene
  //will be removed when it goes off screen
  public func removePhysics() {
    self.node.isHidden = true
  }
  
}
