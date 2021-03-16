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
  @Published public var gameDone: Bool = false
  @Published public var players: [PlayerManager] = []
  
  public enum GameDifficulty {
    case easy, medium, hard
    
    public func getDistanceRange() -> ClosedRange<CGFloat> {
      switch self {
      case .easy:
        return 450...550
      case .medium:
        return 350...450
      case .hard:
        return 210...250
      }
    }
    
    public func getObjectHeightRange() -> ClosedRange<CGFloat> {
      switch self {
      case .easy:
        return 50...100
      case .medium:
        return 100...150
      case .hard:
        return 170...200
      }
    }
  }
  
  public func setGameStatus(done: Bool) {
    if gameDone {
      self.currentGameScore = 0
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
  
  public func getGameDifficulty() -> GameDifficulty {
    if self.currentGameScore > 100 {
      return .hard
    } else if self.currentGameScore > 50 {
      return .medium
    } else {
      return .easy
    }
  }
}
