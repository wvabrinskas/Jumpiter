//
//  Obstacle.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit

public protocol NodeHolder: Identifiable,
                            Equatable,
                            Moveable {
  var node: SKSpriteNode { get set }
}

public class ObstacleHolder: NodeHolder,
                             SpriteBuilder,
                             PhysicsManager,
                             HitTester {
  public var minX: CGFloat?
  public var moveableNode: SKNode?
  public var actionName: String = "move"
  
  var hitTestObject: SKNode {
    return node
  }
  
  public var spriteFrames: [SKTexture] = []
  
  public var id: UUID = UUID()
  public static func == (lhs: ObstacleHolder, rhs: ObstacleHolder) -> Bool {
    return lhs.id == rhs.id
  }
  public var node: SKSpriteNode = SKSpriteNode()
  
  public init(scene: SKScene, origin: CGPoint) {
    minX = -scene.frame.width

    let height = CGFloat.random(in: GameState.shared.getHeightRange())
    
    let newObstacle = self.buildSprite(atlas: "obstacle", texturePrefix: "electric_")
    newObstacle.size = CGSize(width: 100,
                             height: 200)
    
    newObstacle.position = CGPoint(x: origin.x, y: (origin.y + height))
    
    node = newObstacle
    self.moveableNode = node
    self.animateSprite(node)
    
    let obstacleSize = CGSize(width: newObstacle.frame.size.width * 0.5,
                              height: newObstacle.frame.size.height * 0.7)
    self.addPhysics(to: newObstacle, size: obstacleSize, dynamic: false)
  }

}
