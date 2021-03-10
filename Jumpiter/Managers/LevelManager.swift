//
//  LevelManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit
import GameplayKit

public struct Level {
  var groundSize: CGSize
  var obstacleDistanceRange: ClosedRange<CGFloat> = 300...1500
}

public class LevelManager: PhysicsManager {
  public var ground: SKShapeNode
  public var level: Level
  
  private weak var scene: SKScene?
  private var obstacles: [ObstacleHolder] = []
  
  public init(level: Level, scene: SKScene?) {
    self.level = level
    self.scene = scene
    
    self.ground = SKShapeNode(rectOf: level.groundSize)
    self.ground.fillColor = .white
    
    self.addPhysics(to: self.ground, dynamic: false)
    self.ground.physicsBody?.collisionBitMask = 1
  }
  
  public func setup() {
    scene?.addChild(self.ground)
    
    if let scene = scene {
      ground.position = CGPoint(x: 0, y: -(scene.size.height / 2))
    }
  }
  
  private func addObstacle() {
    if let scene = scene {
      let obstacle = ObstacleHolder(scene: scene,
                                    origin: CGPoint(x: (scene.frame.maxX - 50),
                                                    y: ground.frame.maxY))
      
      obstacles.append(obstacle)
      scene.addChild(obstacle.obstacle)
    }
  }
  
  public func didHit(_ obj: SKNode?) -> Bool {
    for i in 0..<self.obstacles.count {
      let obstacle = self.obstacles[i]
      if obstacle.didHit(obj) {
        return true
      }
    }
    return false
  }
  
  public func reset() {
    self.obstacles.forEach { (obs) in
      obs.obstacle.removeFromParent()
    }
    self.obstacles.removeAll()
  }
  
  public func update() {
    let distance = CGFloat.random(in: level.obstacleDistanceRange)

    if let last = self.obstacles.last, let scene = last.obstacle.scene {
      if scene.frame.maxX - abs(last.obstacle.position.x) > distance {
        self.addObstacle()
      }
    } else {
      self.addObstacle()
    }
    
    var copyObstacles = self.obstacles
    
    for i in 0..<self.obstacles.count {
      let obstacle = self.obstacles[i]
      obstacle.move()
      if obstacle.shouldRemove() {
        obstacle.obstacle.removeFromParent()
        copyObstacles.remove(at: i)
      }
    }
    self.obstacles = copyObstacles
  }
}
