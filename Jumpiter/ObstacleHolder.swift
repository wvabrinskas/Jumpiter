//
//  Obstacle.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit


public class ObstacleHolder: Identifiable, Equatable, PhysicsManager, SpriteBuilder {
  var spriteFrames: [SKTexture] = []
  
  public var id: UUID = UUID()
  public static func == (lhs: ObstacleHolder, rhs: ObstacleHolder) -> Bool {
    return lhs.id == rhs.id
  }
  public var obstacle: SKSpriteNode = SKSpriteNode()
  private var minX: CGFloat?
  
  public init(scene: SKScene, origin: CGPoint) {
    minX = -scene.frame.width

    let height = CGFloat.random(in: GameState.shared.getHeightRange())
    
    let newObstacle = self.buildSprite(atlas: "obstacle", texturePrefix: "electric_")
    newObstacle.size = CGSize(width: 100,
                             height: 200)
    
    newObstacle.position = CGPoint(x: origin.x, y: (origin.y + height))
    
    obstacle = newObstacle
    
    self.animateSprite(obstacle)
    self.addPhysics(to: newObstacle, dynamic: false)
  }
  
  public func move() {
    if let action = SKAction(named: "move") {
      obstacle.run(action)
    }
  }
  
  public func shouldRemove() -> Bool {
    guard let min = minX else {
      return true
    }    
    return (obstacle.position.x + obstacle.frame.size.width) < min
  }
  
  public func didHit(_ obj: SKNode?) -> Bool {
    guard let node = obj  else {
      return true
    }

    return node.frame.intersects(obstacle.frame)
  }
}
