//
//  ScoreState.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/9/21.
//

import Foundation
import Combine

class GameState: ObservableObject {
  public static let shared = GameState()
  public var highestScore: Int = 0
  @Published var gameDone: Bool = false
  @Published var players: [PlayerManager] = []
  public var playerStartPosition: CGFloat = 0
  
  public var nearestObstacle: ObstacleHolder?
  
  func setGameStatus(done: Bool) {
    gameDone = done
  }
  
  func setHighestScore(score: Int) {
    highestScore = max(score, highestScore)
  }

  func setPlayers(num: Int) {
    var newPlayers: [PlayerManager] = []
    for _ in 0..<num {
      let manager = PlayerManager()
      newPlayers.append(manager)
    }
    self.players = newPlayers
  }
  
}
