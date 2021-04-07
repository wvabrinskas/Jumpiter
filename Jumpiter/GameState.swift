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
  public var highestWallet: Float = 0
  public var currentGameScore: Int = 0
  public var playerStartPosition: CGFloat = 0
  public var nearestObstacle: ObstacleHolder?
  public var nearestCoin: Coin?

  private var minStartingDistance: CGFloat = 450
  private var maxStartingDistance: CGFloat = 550
  private var minObstacleHeight: CGFloat = 5
  private var maxObstacleHeight: CGFloat = 50
  
  @Published public var gameDone: Bool = false
  @Published public var players: [PlayerManager] = []
  
  public func getDistanceRange() -> ClosedRange<CGFloat> {
    let currentScore = self.currentGameScore
    
    if currentScore % 20 == 0 && minStartingDistance > 250 && maxStartingDistance > 300 {
      self.minStartingDistance -= 1
      self.maxStartingDistance -= 1
    }
        
    return minStartingDistance...maxStartingDistance
  }
  
  public func getHeightRange() -> ClosedRange<CGFloat> {
    let currentScore = self.currentGameScore
    
    if currentScore % 5 == 0 && minObstacleHeight < 75 && maxObstacleHeight < 200 {
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
      minObstacleHeight = 5
      maxObstacleHeight = 50
      nearestCoin = nil
    }
    gameDone = done
  }
  
  public func setHighestWallet(wallet: Float) {
    highestWallet = max(wallet, highestWallet)
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
