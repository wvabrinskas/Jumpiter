//
//  HitTester.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 4/2/21.
//

import Foundation
import SpriteKit

protocol HitTester  {
  var hitTestObject: SKNode { get }
  func didHit(_ obj: SKNode?, useFrame: Bool) -> Bool
}

extension HitTester {
  public func didHit(_ obj: SKNode?, useFrame: Bool = false) -> Bool {
    guard let node = obj,
          let testerBody = hitTestObject.physicsBody,
          let nodeBody = node.physicsBody  else {
      return true
    }
    
    if useFrame {
      return node.frame.contains(hitTestObject.frame.origin)
    }
    
    return nodeBody.allContactedBodies().contains(testerBody)
  }
}
