//
//  ScoreState.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import Combine

public class GameState: ObservableObject {
  public static let shared = GameState()
  public var highestScore: Int = 0
  public var currentGameScore: Int = 0
  public var playerStartPosition: CGFloat = 0
  public var nearestObstacle: ObstacleHolder?
  
  private var minStartingDistance: CGFloat = 450
  private var maxStartingDistance: CGFloat = 550
  private var minObstacleHeight: CGFloat = 50
  private var maxObstacleHeight: CGFloat = 100
  
  @Published public var gameDone: Bool = false
  @Published public var players: [PlayerManager] = []
  
  public func getDistanceRange() -> ClosedRange<CGFloat> {
    let currentScore = self.currentGameScore
    
    if currentScore % 20 == 0 && minStartingDistance > 220 && maxStartingDistance > 270 {
      self.minStartingDistance -= 1
      self.maxStartingDistance -= 1
    }
        
    return minStartingDistance...maxStartingDistance
  }
  
  public func getHeightRange() -> ClosedRange<CGFloat> {
    let currentScore = self.currentGameScore
    
    if currentScore % 10 == 0 && minObstacleHeight < 150 && maxObstacleHeight < 200 {
      self.minObstacleHeight += 5
      self.maxObstacleHeight += 5
    }
        
    return minObstacleHeight...maxObstacleHeight
  }
  
  public func setGameStatus(done: Bool) {
    if gameDone {
      self.currentGameScore = 0
      minStartingDistance = 450
      maxStartingDistance = 550
      minObstacleHeight = 50
      maxObstacleHeight = 100
    }
    gameDone = done
  }
  
  public func setHighestScore(score: Int) {
    highestScore = max(score, highestScore)
  }
  
  public func updateCurrentScore() {
    if let first = self.players.first(where: { !$0.isDead }) {
      currentGameScore = first.score
    }
  }

  public func setPlayers(num: Int) {
    var newPlayers: [PlayerManager] = []
    for _ in 0..<num {
      let manager = PlayerManager()
      newPlayers.append(manager)
    }
    self.players = newPlayers
  }

}
