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
  let minStartingDistance = 450
  let maxStartingDistance = 550
}

public class LevelManager: PhysicsManager {
  public var ground: SKShapeNode
  public var level: Level
  
  private weak var scene: SKScene?
  private var obstacles: [ObstacleHolder] = []
  private var coins: [Coin] = []
  
  public init(level: Level, scene: SKScene?) {
    self.level = level
    self.scene = scene
    
    self.ground = SKShapeNode(rectOf: level.groundSize)
    self.ground.fillColor = .white
    self.ground.zPosition = 1
    
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
                                    origin: CGPoint(x: (scene.frame.maxX),
                                                    y: ground.frame.maxY))
      
      obstacles.append(obstacle)
      scene.addChild(obstacle.obstacle)
    }
  }
  
  private func addCoin(x: CGFloat) {
    if let scene = scene {
      let randomY = CGFloat.random(in: -50...100)
      let point = CGPoint(x: x, y: randomY)
      let maker = CoinMaker(pos: point)
      let coin = Coin(maker: maker, scene: scene)
      coins.append(coin)
      
      scene.addChild(coin.coin)
    }
  }
  
  public func nearestObstacle() -> ObstacleHolder? {
    let adjustedPlayerPosition = GameState.shared.playerStartPosition
    
    let first = self.obstacles.first { (obst) -> Bool in
      let obstaclePos = obst.obstacle.position.x + obst.obstacle.frame.size.width
      if obstaclePos > adjustedPlayerPosition {
        return true
      } else {
        return false
      }
    }

    return first
  }
  
  public func nearestCoin() -> Coin? {
    let adjustedPlayerPosition = GameState.shared.playerStartPosition
    
    let first = self.coins.first { (obst) -> Bool in
      let obstaclePos = obst.coin.position.x + obst.coin.frame.size.width
      if obstaclePos > adjustedPlayerPosition {
        return true
      } else {
        return false
      }
    }

    return first
  }
  
  public func didHitObstacle(_ obj: SKNode?) -> Bool {
    if let nearest = self.nearestObstacle() {
      return nearest.didHit(obj)
    }
    return false
  }
  
  public func didHitCoin(_ obj: SKNode?) -> Bool {
    if let nearest = self.nearestCoin() {
      return nearest.didHit(obj)
    }
    return false
  }
  
  public func reset() {
    self.obstacles.forEach { (obs) in
      obs.obstacle.removeFromParent()
    }
    self.obstacles.removeAll()
  }
  
  //gets called once a frame
  public func update() {
    let distance = CGFloat.random(in: GameState.shared.getDistanceRange())

    if let last = self.obstacles.last, let scene = last.obstacle.scene {
      if scene.frame.maxX - abs(last.obstacle.position.x) > distance {
        self.addObstacle()
      } else if scene.frame.maxX - abs(last.obstacle.position.x) > (distance / 2) {
        let x = scene.frame.maxX - abs(last.obstacle.position.x)
        self.addCoin(x: x)
      }
    } else {
      self.addObstacle()
    }
    
    var copyObstacles = self.obstacles
    var copyCoins = self.coins

    for i in 0..<self.coins.count {
      let coin = self.coins[i]
      coin.move()
      
      if coin.shouldRemove() {
        coin.gotCoin()
        copyCoins.remove(at: i)
      }
    }
    
    self.coins = copyCoins
    
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
