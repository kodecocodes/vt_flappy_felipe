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

  let impulse: CGFloat = 400
  var velocity = CGPoint.zero
  let gravity: CGFloat = -1500

  var playableStart: CGFloat = 0

  init(entity: GKEntity) {
    self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyImpulse(_ lastUpdateTime: TimeInterval) {
    velocity = CGPoint(x: 0, y: impulse)
  }

  func applyMovement(_ seconds: TimeInterval) {
    let spriteNode = spriteComponent.node

    // Apply Gravity
    let gravityStep = CGPoint(x: 0, y: gravity) * CGFloat(seconds)
    velocity += gravityStep

    // Apply Velocity
    let velocityStep = velocity * CGFloat(seconds)
    spriteNode.position += velocityStep

    // Temporary Ground Hit
    if spriteNode.position.y - spriteNode.size.height / 2 < playableStart {
      spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableStart + spriteNode.size.height / 2)
    }
  }

  override func update(deltaTime seconds: TimeInterval) {
    if let player = entity as? PlayerEntity {
      applyMovement(seconds)
    }
  }
}
