//
//  GameScene.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import SpriteKit
import GameplayKit
import Combine

class GameScene: SKScene, PhysicsManager {
  private let gameState: GameState = .shared
  private var scoreLabels: [SKLabelNode] = []
  private var highScoreLabel: SKLabelNode?
  private var generationLabel: SKLabelNode?
  private var scoreLabel: SKLabelNode?
  private var aliveLabel: SKLabelNode?

  private var lastUpdateTime : TimeInterval = 0
  
  private var players: [PlayerManager] = []
  private var playerCancellable: AnyCancellable?
  private let brainManager = GameBrainManager()
  private let aiControlled = true
  
  private lazy var levelManager: LevelManager = {
    var size: CGSize = .zero
    if let scene = scene {
      size = CGSize(width: scene.size.width, height: 100)
    }
    
    let level = Level(groundSize: size)
    return LevelManager(level: level, scene: self)
  }()

  private enum Keys: UInt16 {
    case space = 49
    case up = 126
    case down = 125
    case r = 15
  }
  
  override func sceneDidLoad() {
    self.scaleMode = .aspectFit

    self.gameState.playerStartPosition = self.frame.minX * 0.3

    self.lastUpdateTime = 0
    
    self.playerCancellable = self.gameState.$players.sink(receiveValue: { (value) in
      guard value.count > 0 else {
        return
      }
      self.players = value
      value.forEach { (player) in
        player.setup(in: self)
      }
      self.reset()
    })
    
    brainManager.setup()
    brainManager.delegate = self
    
    highScoreLabel = self.childNode(withName: "\\gen") as? SKLabelNode
    generationLabel = self.childNode(withName: "\\generation") as? SKLabelNode
    aliveLabel = self.childNode(withName: "\\galive") as? SKLabelNode
    scoreLabel = self.childNode(withName: "\\gscore") as? SKLabelNode
  }
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    self.startPhysics(world: self.physicsWorld, gravity: -27)
    
    self.levelManager.setup()

    self.setupLabels()
  }
  
  override func keyDown(with event: NSEvent) {
    guard !aiControlled else {
      return
    }
    
    switch event.keyCode {
    case Keys.space.rawValue, Keys.up.rawValue: //space
      self.jump()
    case Keys.r.rawValue:
      self.reset()
    default:
      print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
    }
  }
  
  private func setupLabels() {
    self.highScoreLabel?.text = "\(self.gameState.highestScore)"
    self.scoreLabel?.text = "\(self.gameState.currentGameScore)"

    guard self.players.count <= 20 else {
      return
    }
    
    guard self.scoreLabels.count == 0 else {
      var i = 0
      self.players.forEach { (manager) in
        self.scoreLabels[i].text = "Player \(i + 1): \(manager.score)"
        i += 1
      }
      return
    }
    
    var i = 0
    let spacing: CGFloat = 30
    self.players.forEach { (manager) in
      let label = SKLabelNode(text: "Player \(i + 1): \(manager.score)")
      self.scoreLabels.append(label)
      label.fontSize = 22
      label.fontName = "Helvetica Neue Bold"
      label.position = CGPoint(x: self.frame.minX + 10, y: (self.frame.maxY - 30) - spacing * CGFloat(i))
      label.fontColor = manager.color
      label.horizontalAlignmentMode = .left
      self.addChild(label)
      i += 1
    }
  }
  
  internal func reset() {
    self.players.forEach { (manager) in
      manager.reset()
      if manager.player.scene == nil {
        self.addChild(manager.player)
        manager.player.position = CGPoint(x: gameState.playerStartPosition , y: 0)
      }
    }
    self.gameState.setGameStatus(done: false)
    self.levelManager.reset()
  }
  
  public func jump(at index: Int? = nil) {
    if let index = index {
      guard index <= self.players.count - 1 else {
        return
      }
      let player = self.players[index]
      
      guard let body = player.player.physicsBody,
            let groundBody = self.levelManager.ground.physicsBody,
            player.isDead == false else {
        return
      }
      
      if body.allContactedBodies().contains(groundBody) {
        player.jump()
      }
    } else {
      
      //have each manager jump
      DispatchQueue.concurrentPerform(iterations: self.players.count) { (i) in
        let manager = self.players[i]
        guard let body = manager.player.physicsBody,
              let groundBody = self.levelManager.ground.physicsBody,
              manager.isDead == false else {
          return
        }
        if body.allContactedBodies().contains(groundBody) {
          manager.jump()
        }
      }
    }
  }
  
  private func updateAliveLabel() {
    let playersCount = players.filter({ !$0.isDead })
    
    self.aliveLabel?.text = "\(playersCount.count)"
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered

    //mulitple players
    var allPlayersDead = true
    
    if !self.gameState.gameDone {
      
      if let closest = self.levelManager.nearestObstacle(),
         closest != gameState.nearestObstacle {
        
        gameState.nearestObstacle = closest
      }
      
      DispatchQueue.concurrentPerform(iterations: self.players.count) { (i) in
        let manager = self.players[i]
        if self.levelManager.didHit(manager.player) {
          manager.isDead = true
        } else {
          if round(currentTime).truncatingRemainder(dividingBy: 1) == 0 &&
              self.lastUpdateTime != round(currentTime) &&
              !manager.isDead {
            manager.updateScore()
          }
        }
        if !manager.isDead {
          allPlayersDead = false
        }
      }

      if !allPlayersDead {
        self.brainManager.feed(self.frame)
        self.levelManager.update()
        self.setupLabels()
        self.updateAliveLabel()
        self.gameState.updateCurrentScore()
      } else {
        self.gameState.setGameStatus(done: true)
      }
    }
   
    self.lastUpdateTime = round(currentTime)
  }
}

extension GameScene: GameBrainManagerDelegate {
  func jump(index: Int) {
    self.jump(at: index)
  }
  
  func resetGame(_ highestScore: Double, _ generation: Int) {
    DispatchQueue.main.async {
      self.reset()
      self.generationLabel?.text = "\(generation)"
    }
  }
}
