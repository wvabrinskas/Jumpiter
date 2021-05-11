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
  
  private var level: Level?
  
  @Published public var gameDone: Bool = false
  @Published public var players: [PlayerManager] = []
  
  public func setGameStatus(done: Bool) {
    if gameDone {
      self.currentGameScore = 0
      nearestCoin = nil
    }
    gameDone = done
  }
  
  public func setLevel(level: Level) {
    self.level = level
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
