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
  private var lastUpdateTime : TimeInterval = 0
  
  private var players: [PlayerManager] = []
  private var playerCancellable: AnyCancellable?
  
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
    
    self.gameState.setPlayers(num: 2)
  }

  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    self.startPhysics(world: self.physicsWorld, gravity: -25)
    
    self.levelManager.setup()

    self.setupLabels()
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case Keys.space.rawValue, Keys.up.rawValue: //space
      self.jump(at: 0)
    case Keys.r.rawValue:
      self.reset()
    default:
      print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
    }
  }
  
  private func setupLabels() {
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
      label.fontName = "Helvetica Nueue Bold"
      label.position = CGPoint(x: self.frame.minX + 80, y: (self.frame.maxY - 30) - spacing * CGFloat(i))
      label.fontColor = manager.color
      self.addChild(label)
      i += 1
    }
  }
  
  private func reset() {
    self.players.forEach { (manager) in
      manager.resetScore()
      manager.isDead = false
      if manager.player.scene == nil {
        self.addChild(manager.player)
      }
    }
    self.gameState.gameDone = false
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
      self.players.forEach { (manager) in
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
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered

    //mulitple players
    var allPlayersDead = true
    
    if !self.gameState.gameDone {
      
      self.players.forEach { (manager) in
        if self.levelManager.didHit(manager.player) {
          manager.isDead = true
        } else {
          allPlayersDead = false
          if round(currentTime).truncatingRemainder(dividingBy: 1) == 0 &&
              self.lastUpdateTime != round(currentTime) &&
              !manager.isDead {
            manager.updateScore()
          }
        }
      }
    }
    
    if !allPlayersDead {
      self.levelManager.update()
      self.setupLabels()
    } else {
      self.gameState.gameDone = true
    }
    
    self.lastUpdateTime = round(currentTime)
  }
}
