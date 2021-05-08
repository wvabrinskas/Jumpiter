//
//  LevelManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import SpriteKit
import GameplayKit

@propertyWrapper struct RangeCapped<T: Numeric & Comparable> {
  var range: ClosedRange<T>
  var wrappedValue: T {
    didSet {
      wrappedValue = min(max(range.lowerBound, wrappedValue), range.upperBound)
    }
  }
  init(wrappedValue: T, range: ClosedRange<T>) {
    self.range = range
    self.wrappedValue = min(max(range.lowerBound, wrappedValue), range.upperBound)
  }
}

public struct Level {
  var groundSize: CGSize
  var minStartingDistance: CGFloat = 450
  var maxStartingDistance: CGFloat = 550
  @RangeCapped(range: 0...100) var coinRandomness: Int = 4
}
 
public class LevelManager: PhysicsManager {
  public var ground: SKShapeNode
  public var level: Level
  
  private weak var scene: SKScene?
  private var obstacles: [ObstacleHolder] = []
  private var coins: [Coin] = []
  private var discardedNodes: [Moveable] = []
  
  enum UpdateState {
    case obstacles
    case coins
    case discarded
  }
  
  public init(level: Level, scene: SKScene?) {
    self.level = level
    self.scene = scene
    
    self.ground = SKShapeNode(rectOf: level.groundSize)
    self.ground.fillColor = .white
    self.ground.zPosition = 1
    
    self.addPhysics(to: self.ground, size: self.ground.frame.size, dynamic: false)
    self.ground.physicsBody?.categoryBitMask = 0b0001
    self.ground.physicsBody?.contactTestBitMask = ContactBitMasks.ground.rawValue
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
      scene.addChild(obstacle.node)
    }
  }
  
  private func addCoin(x: CGFloat) {
    let random = Int.random(in: 0...level.coinRandomness)
    if let scene = scene, random == 1 {
      let randomY = CGFloat.random(in: 150 + scene.frame.minY...scene.frame.midY)
      let point = CGPoint(x: x, y: randomY)
      let maker = CoinMaker(pos: point)
      let coin = Coin(maker: maker, scene: scene)
      coins.append(coin)
      scene.addChild(coin.node)
    }
  }
  
  public func nearestObstacle() -> ObstacleHolder? {
    return self.obstacles.first
  }
  
  public func nearestCoin() -> Coin? {
    return self.coins.first
  }
  
  public func collectedCoin(coin: Coin) {
    coin.node.removeFromParent()
    if self.coins.contains(coin) {
      self.coins = self.coins.filter({ $0.id != coin.id })
    }
  }
  
  public func didHitObstacle(_ obj: SKNode?) -> Bool {
    if let nearest = self.nearestObstacle() {
      return nearest.didHit(obj)
    }
    return false
  }
  
  public func reset() {
    self.obstacles.forEach { (obs) in
      obs.node.removeFromParent()
    }
    self.obstacles.removeAll()
    
    self.coins.forEach { coin in
      coin.node.removeFromParent()
    }
    self.coins.removeAll()
    
    self.discardedNodes.forEach { discarded in
      discarded.moveableNode?.removeFromParent()
    }
    self.discardedNodes.removeAll()
  }
  
  //gets called once a frame
  public func update() {
    self.state(update: .obstacles)
    self.state(update: .coins)
    self.state(update: .discarded)
    
    let distance = CGFloat.random(in: GameState.shared.getDistanceRange())

    if let last = self.obstacles.last, let scene = self.scene {
      if scene.frame.maxX - abs(last.node.position.x) > distance {
        self.addObstacle()
    
        let coinX = scene.frame.maxX + (distance / 2)
        self.addCoin(x: coinX)
      }
    } else {
      self.addObstacle()
    }
  }
  
  func state(update: UpdateState) {
    switch update {
    case .coins:
      self.coins = self.update(array: self.coins)
      if self.coins.count == 0 {
        GameState.shared.nearestCoin = nil
      }
    case .obstacles:
      self.obstacles = self.update(array: self.obstacles)
      if self.obstacles.count == 0 {
        GameState.shared.nearestObstacle = nil
      }
    case .discarded:
      self.updateDiscarded()
    }
  }
  
  func updateDiscarded() {
    var copyObstacles = discardedNodes
    
    for i in 0..<discardedNodes.count {
      let node = discardedNodes[i]
      node.move()
      
      if node.shouldRemove() {
        node.moveableNode?.removeFromParent()
        copyObstacles.remove(at: i)
      }
    }
    discardedNodes = copyObstacles
  }

  func update<T: NodeHolder>(array: [T]) -> [T] {
    let playerPosition = GameState.shared.playerStartPosition
    var copyObstacles = array
    
    for i in 0..<array.count {
      let obstacle = array[i]
      obstacle.move()
     
      if obstacle.node.position.x + obstacle.node.frame.size.width < playerPosition {
        copyObstacles.remove(at: i)
        self.discardedNodes.append(obstacle)
      }
    }
    return copyObstacles
  }
}
