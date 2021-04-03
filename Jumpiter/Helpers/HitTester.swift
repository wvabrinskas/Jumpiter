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
  func didHit(_ obj: SKNode?) -> Bool
}

extension HitTester {
  public func didHit(_ obj: SKNode?) -> Bool {
    guard let node = obj  else {
      return true
    }

    return node.frame.intersects(hitTestObject.frame)
  }
}
