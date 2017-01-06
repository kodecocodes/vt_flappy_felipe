/*
* Copyright (c) 2017 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit
import GameplayKit

class MovementComponent: GKComponent {
  
  let spriteComponent: SpriteComponent
  
  var velocity = CGPoint.zero
  let gravity: CGFloat = -1500
  let impulse: CGFloat = 400
  
  var velocityModifier: CGFloat = 1000.0
  var angularVelocity: CGFloat = 0.0
  let minDegrees: CGFloat = -90
  let maxDegrees: CGFloat = 25
  
  var lastTouchTime: TimeInterval = 0
  var lastTouchY: CGFloat = 0.0
  
  var playableStart: CGFloat = 0
  
  let flapAction = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
  
  init(entity: GKEntity) {
    self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func applyInitialImpulse() {
    velocity = CGPoint(x: 0, y: impulse * 2)
  }
  
  func moveSombrero() {
    if let player = entity as? Player {
      let moveUp = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
      moveUp.timingMode = .easeInEaseOut
      let moveDown = moveUp.reversed()
      player.sombrero.run(SKAction.sequence([moveUp, moveDown]))
    }
  }
  
  func applyImpulse(_ lastUpdateTime: TimeInterval) {
    
    spriteComponent.node.run(flapAction)
    
    moveSombrero()
    
    velocity = CGPoint(x: 0, y: impulse)
    
    angularVelocity = velocityModifier.degreesToRadians()
    lastTouchTime = lastUpdateTime
    lastTouchY = spriteComponent.node.position.y
  }
  
  func applyMovement(_ seconds: TimeInterval) {
    let spriteNode = spriteComponent.node
    
    // Apply gravity
    let gravityStep = CGPoint(x: 0, y: gravity) * CGFloat(seconds)
    velocity += gravityStep
    
    // Apply velocity
    let velocityStep = velocity * CGFloat(seconds)
    spriteNode.position += velocityStep
    
    if spriteNode.position.y < lastTouchY {
      angularVelocity = -velocityModifier.degreesToRadians()
    }
    
    // Rotate
    let angularStep = angularVelocity * CGFloat(seconds)
    spriteNode.zRotation += angularStep
    spriteNode.zRotation = min(max(spriteNode.zRotation, minDegrees.degreesToRadians()), maxDegrees.degreesToRadians())
    
    // Temporary ground hit
    if spriteNode.position.y - spriteNode.size.height/2 < playableStart {
      spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableStart + spriteNode.size.height/2)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    if let player = entity as? Player {
      if player.movementAllowed {
        applyMovement(seconds)
      }
    }
  }
}
