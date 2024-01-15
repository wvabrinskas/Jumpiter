//
//  GameBrainManager.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 3/10/21.
//

import Foundation
import Neuron
import Genetic
import Combine
import NumSwift

public struct Stat<T> {
  public var label: String
  public var stat: T
}

protocol GameBrainManagerDelegate: AnyObject {
  func jump(index: Int)
  func resetGame(_ highestScore: Double, _ generation: Int)
}

class GameBrainManager: ObservableObject {
  private let state: GameState = .shared
  private let rankingExponent = 2.0
  private let inputs = 4
  private let hiddenNodes = 3
  private let numberOfChildren = 200
  private var brains: [Sequential] = []
  private var gameDoneCancellable: AnyCancellable?
  private var gameOver: Bool = false
  private var networkShape: [[Int]] = []
  public weak var delegate: GameBrainManagerDelegate?
  @Published public var stats: [Stat<Float>] = []
  
  private lazy var gene: Genetic = {
    Genetic<Float>(mutationFactor: 10, numberOfChildren: numberOfChildren)
  }()
  
  init(_ delegate: GameBrainManagerDelegate? = nil) {
    self.delegate = delegate
    
    gene.fitnessFunction = { (number: [Float], index: Int) -> Double in
      guard index < self.state.players.count else {
        return 0
      }
      
      let player = self.state.players[index]
      
      //let result: Double = Double(player.score) * (1 + (Double(player.wallet) / 20))
      let result: Double = Double(player.score) - (Double(player.numOfJumps) * 0.2) // + Double(player.wallet)

      let powerResult = pow(result, self.rankingExponent)
      
      return powerResult
    }
    
    gene.mutationFunction = { [weak self] () -> Float in
      guard let self else { return 0 }
      return InitializerType.xavierUniform.build().calculate(input: inputs, out: hiddenNodes)
    }
    
    var initialPop: [[Float]] = []
    for _ in 0..<numberOfChildren {
      let brain = self.getBrain()
      brains.append(brain)
      initialPop.append(self.flattenedWeights(brain))
    }
    
    gene.startingPopulation = initialPop
    
    self.gameDoneCancellable = state.$gameDone.sink(receiveValue: { (done) in
      self.gameOver = done
      if done {
        //apply genetic
        let newPop = self.gene.apply()
        for i in 0..<newPop.count {
          let newGeneWeights = newPop[i]
          let brain = self.brains[i]
          self.replace(newGeneWeights, for: brain)
        }
        self.delegate?.resetGame(self.gene.highestRanking,
                                 self.gene.generations)
      }
    })
  }
  
  public func setup() {
    self.state.setPlayers(num: numberOfChildren)
  }
  
  private func flattenedWeights(_ network: Sequential) -> [Tensor.Scalar] {
    
    do {
      let weights: [[Tensor.Scalar]] = try network.exportWeights().flatMap { $0 }.compactMap { $0.value.fullFlatten() }
      return weights.flatten()
    } catch {
      print(error.localizedDescription)
    }

    return []
  }
  
  private func replace(_ weights: [Tensor.Scalar], for network: Sequential) {
    var newWeights: [[Tensor]] = []
    var layer: Int = 0
    var lastTotal: Int = 0
    
    if let flatNetwork: [Tensor] = try? network.exportWeights().fullFlatten() { // we full flatten because Dense only has one dimension
      
      flatNetwork.forEach { t in
        let shape = t.shape
        if shape == [0] { // this means we have an activation layer
          newWeights.append([Tensor()])
        } else {
          let total = shape[safe: 0, 0] * shape[safe: 1, 0]
          let offset = (lastTotal * layer)
          let flatWeights = Array(weights[offset..<(offset + total)])
          
          let reshapedWeights = flatWeights.reshape(columns: shape[safe: 0, 1])
          let weightTensor = Tensor(reshapedWeights)
          newWeights.append([weightTensor])
          
          lastTotal = total
          layer += 1
        }
      }
      workingWeights.append(hiddenWeights)
    }
    
    do {
      try network.importWeights(newWeights)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  private func getBrain() -> Sequential {
    
    let network = Sequential {[
      Dense(hiddenNodes,
            inputs: inputs,
            biasEnabled: false),
      LeakyReLu(),
      Dense(hiddenNodes,
            inputs: inputs,
            biasEnabled: false),
      LeakyReLu(),
      Dense(1),
      Sigmoid()
    ]}
    
    network.compile()
    
    if networkShape.isEmpty, let flatNetwork: [Tensor] = try? network.exportWeights().fullFlatten() {
      networkShape = flatNetwork.map { $0.shape }
    }
    
    return network
  }
  
  private func publishStats(_ stats: [Float]) {
    var newStats: [Stat<Float>] = []
    
    let statLabels = ["Obstacle X",
                      "Obstacle Y",
                      "Coin X",
                      "Coin Y"]
    
    guard statLabels.count == stats.count else {
      print("ERROR: labels count does not match stats count")
      return
    }
    
    for i in 0..<stats.count {
      let stat = stats[i]
      let label = statLabels[i]
      newStats.append(Stat(label: label, stat: stat))
    }
    
    self.stats = newStats
  }
  
  public func feed(_ frame: CGRect) {
    let mapRange: ClosedRange<CGFloat> = 0...1
    
    for i in 0..<brains.count {
      let player = self.state.players[i]
      
      let playerPosX = player.player.position.x + player.player.frame.size.width

      var mappedXPos: Float = Float(mapRange.upperBound)
      var mappedYPos: Float = Float(mapRange.lowerBound)
      
      if let obstacle = self.state.nearestObstacle {
        let obstacleXPos = obstacle.node.position.x - (obstacle.node.frame.size.width / 2)
        let obstacleYPos = obstacle.node.position.y + (obstacle.node.frame.size.height / 2)
        
        mappedXPos = Float(obstacleXPos).map(from: playerPosX...frame.maxX, to: mapRange)
        mappedYPos = Float(obstacleYPos).map(from: frame.minY...frame.midY, to: mapRange)
        
      }
      
      var mappedCoinXPos: Float = Float(mapRange.upperBound)
      var mappedCoinYPos: Float = Float(mapRange.lowerBound)
      
      if let coin = self.state.nearestCoin {
        let coinXPos: CGFloat = coin.node.position.x - (coin.node.frame.size.width / 2)
        let coinYPos: CGFloat = coin.node.position.y + (coin.node.frame.size.height / 2)
        
        mappedCoinXPos = Float(coinXPos).map(from: playerPosX...frame.maxX, to: mapRange)
        mappedCoinYPos = Float(coinYPos).map(from: frame.minY...frame.midY, to: mapRange) //closer the better
      }
      
      let inputs: [Float] = [mappedXPos,
                             mappedYPos,
                             mappedCoinXPos,
                             mappedCoinYPos]
    
      self.publishStats(inputs)
      
      let brain = brains[i]
      let results = brain(Tensor(inputs))
      //only one output
      let output = results.asScalar()
      
      if output >= 0.9 {
        self.delegate?.jump(index: i)
      }
    }
  }
}
