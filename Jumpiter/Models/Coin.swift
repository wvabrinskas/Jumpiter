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

public class Coin: SpriteBuilder {
  internal var spriteFrames: [SKTexture] = []
  public var value: Int
  public var coin: SKSpriteNode = SKSpriteNode()
  public var position: CGPoint
  
  public init(maker: CoinMaker) {
    self.value = maker.value
    self.position = maker.pos
    self.buildCoin()
  }
  
  private func buildCoin() {
    self.coin = self.buildSprite(atlas: "coin", texturePrefix: "coin_")
    self.coin.position = self.position
    self.animateSprite(coin)
  }
  
}
