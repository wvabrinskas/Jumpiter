//
//  SpriteBuilder.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/16/21.
//

import Foundation
import SpriteKit


protocol SpriteBuilder: class {
  var spriteFrames: [SKTexture] { get set }
  
  func buildSprite(atlas name: String, texturePrefix: String) -> SKSpriteNode
  func animateSprite(_ sprite: SKSpriteNode, interval: TimeInterval)
}

extension SpriteBuilder {
  func buildSprite(atlas name: String, texturePrefix: String) -> SKSpriteNode {
    let atlas = SKTextureAtlas(named: name)
    var walkFrames: [SKTexture] = []

    let numImages = atlas.textureNames.count
    for i in 0..<numImages {
      let bearTextureName = "\(texturePrefix)\(i)"
      walkFrames.append(atlas.textureNamed(bearTextureName))
    }
    
    self.spriteFrames = walkFrames
    let firstFrameTexture = spriteFrames[0]
    return SKSpriteNode(texture: firstFrameTexture)
  }
  
  func animateSprite(_ sprite: SKSpriteNode, interval: TimeInterval = 0.1) {
    sprite.run(SKAction.repeatForever(
                SKAction.animate(with: self.spriteFrames,
                                 timePerFrame: interval,
                                 resize: false,
                                 restore: true)),
               withKey:"animating-\(UUID().uuidString)")
  }
}
