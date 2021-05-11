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

protocol GameBrainManagerDelegate: class {
  func jump(index: Int)
  func resetGame(_ highestScore: Double, _ generation: Int)
}

class GameBrainManager {
  private let state: GameState = .shared
  private let rankingExponent = 2.0
  private let inputs = 4
  private let hiddenNodes = 3
  private let outputs = 2
  private let numOfHiddenLayers = 1
  private let numberOfChildren = 100
  private var brains: [Brain] = []
  private var gameDoneCancellable: AnyCancellable?
  private var gameOver: Bool = false
  public weak var delegate: GameBrainManagerDelegate?
  
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
      
      let result: Double = Double(player.score) * (1 + (Double(player.wallet) / 20))
      
      let powerResult = pow(result, self.rankingExponent)
      
      return powerResult
    }
    
    gene.mutationFunction = { () -> Float in
      return Float.random(in: 0...1)
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
  
  private func flattenedWeights(_ brain: Brain) -> [Float] {
    var flattenedWeights: [Float] = []
    
    for lobe in brain.lobes {
      lobe.neurons.forEach { (neuron) in
        let weights = neuron.inputs.map({ $0.weight })
        flattenedWeights.append(contentsOf: weights)
      }
    }
    
    return flattenedWeights
  }
  
  private func replace(_ weights: [Float], for brain: Brain) {
    //THIS IS HORRIBLE FIX THIS
    
    //turn weights into 2D array
    var copyWeights = weights
    var workingWeights: [[Float]] = []
    
    for i in 0..<inputs {
      workingWeights.append([copyWeights[i]])
      copyWeights.remove(at: i)
    }
    
    for i in 0..<numOfHiddenLayers {
      for _ in 0..<hiddenNodes {
        if i > 0 {
          workingWeights.append(Array(copyWeights[0..<hiddenNodes]))
          copyWeights.removeSubrange(0..<hiddenNodes)
        } else {
          workingWeights.append(Array(copyWeights[0..<inputs]))
          copyWeights.removeSubrange(0..<inputs)
        }
        
      }
    }
    
    for _ in 0..<outputs {
      workingWeights.append(Array(copyWeights[0..<hiddenNodes]))
      copyWeights.removeSubrange(0..<hiddenNodes)
    }
    
    brain.replaceWeights(weights: workingWeights)
  }
  
  private func getBrain() -> Brain {
    let bias: Float = 0.01
    
    let brain = Brain(learningRate: 0,
                      epochs: 200,
                      lossFunction: .crossEntropy,
                      lossThreshold: 0.001,
                      initializer: .xavierNormal)
    
    brain.add(.init(nodes: self.inputs, bias: bias)) //input layer
    
    for _ in 0..<numOfHiddenLayers {
      brain.add(.init(nodes: self.hiddenNodes, activation: .reLu, bias: bias)) //hidden layer
    }
    
    brain.add(.init(nodes: self.outputs, activation: .reLu, bias: bias)) //output layer
    brain.add(optimizer: .adam())
    brain.add(modifier: .softmax)
    
    brain.logLevel = .none
    
    brain.compile()
    
    return brain
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
            
      let brain = brains[i]
      let results = brain.feed(input: inputs)
      //only one output
      if let argmax = results.max(), let index = results.firstIndex(of: argmax) {
        if index == 0 {
          self.delegate?.jump(index: i)
        }
      }
    }
  }
}
