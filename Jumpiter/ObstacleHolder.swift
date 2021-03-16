//
//  Obstacle.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit


public struct ObstacleHolder: Identifiable, Equatable, PhysicsManager {
  public var id: UUID = UUID()
  
  public var obstacle: SKNode
  public var height: CGFloat
  private var minX: CGFloat?
  
  public init(scene: SKScene, origin: CGPoint) {
    minX = -scene.frame.width
    
    let height = CGFloat.random(in: GameState.shared.getGameDifficulty().getObjectHeightRange())
    self.height = height

    let newObstacle = SKShapeNode(rectOf: CGSize(width: 50,
                                                 height: height))
    newObstacle.position = CGPoint(x: origin.x, y: (origin.y + (height / 2)))
    newObstacle.fillColor = .systemRed
    newObstacle.strokeColor = .clear
    
    obstacle = newObstacle
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
