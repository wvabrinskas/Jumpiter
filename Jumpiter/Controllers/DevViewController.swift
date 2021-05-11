//
//  DevViewController.swift
//  Jumpiter
//
//  Created by William Vabrinskas on 5/10/21.
//

import Foundation
import Cocoa

public protocol StatsReceiever {
  associatedtype T
  func update(_ stats: [Stat<T>])
}

class StatView: NSView {
  let titleLabel = NSText(frame: .zero)
  let statlabel = NSText(frame: .zero)
  let stackView = NSStackView(frame: .zero)
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    self.frame = frameRect
    self.stackView.frame = frameRect
    self.stackView.orientation = .horizontal
    self.stackView.addArrangedSubview(titleLabel)
    self.stackView.addArrangedSubview(statlabel)
    self.addSubview(self.stackView)
  }
  
  public func update<T>(stat: Stat<T>) {
    self.titleLabel.string = stat.label
    self.statlabel.string = "\(stat.stat)"
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

class DevViewController<TStat>: NSViewController, StatsReceiever {
  typealias T = TStat
  
  private var laidOut = false
  private var statViews: [StatView] = []
  private lazy var statStackView: NSStackView = {
    let view = NSStackView(views: statViews)
    view.orientation = .vertical
    return view
  }()
  
  private var stats: [Stat<T>] = [] {
    didSet {
      self.setNewStats()
    }
  }

  override func loadView() {
    self.view = NSView()
    self.view.frame = NSRect(x: 0, y: 0, width: 300, height: 600)
  }
  
  public func update(_ stats: [Stat<T>]) {
    self.stats = stats
  }
  
  private func setNewStats() {
    if self.statViews.count == 0 {
      self.stats.forEach { stat in
        let view = StatView(frame: NSRect(x: 0,
                                          y: 0,
                                          width: self.view.frame.width,
                                          height: 100))
        view.update(stat: stat)
        self.statViews.append(view)
        self.statStackView.addArrangedSubview(view)
      }
      print("stats :\(self.stats)")

      if !self.laidOut {
        self.view.addSubview(self.statStackView)
        
        self.statStackView.translatesAutoresizingMaskIntoConstraints = false
        self.statStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.statStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.statStackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.statStackView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        self.laidOut = true
      }
    } else {
      for i in 0..<self.statViews.count {
        let statView = self.statViews[i]
        let stat = self.stats[i]
        statView.update(stat: stat)
      }
    }
  }
}
