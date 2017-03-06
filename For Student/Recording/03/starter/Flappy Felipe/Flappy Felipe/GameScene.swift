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

enum Layer: CGFloat {
  case background
  case foreground
}

class GameScene: SKScene {

  let worldNode = SKNode()
  var playableStart: CGFloat = 0
  var playableHeight: CGFloat = 0

  override func didMove(to view: SKView) {
    addChild(worldNode)
    setupBackground()
    setupForeground()
  }

  func setupBackground() {
    let background = SKSpriteNode(imageNamed: "Background")
    background.anchorPoint = CGPoint(x: 0.5, y: 1.0)
    background.position = CGPoint(x: size.width / 2, y: size.height)
    background.zPosition = Layer.background.rawValue

    playableStart = size.height - background.size.height
    playableHeight = background.size.height

    worldNode.addChild(background)
  }

  func setupForeground() {
    let foreground = SKSpriteNode(imageNamed: "Ground")
    foreground.anchorPoint = CGPoint(x: 0.0, y: 1.0)
    foreground.position = CGPoint(x: 0, y: playableStart)
    foreground.zPosition = Layer.foreground.rawValue

    worldNode.addChild(foreground)
  }
}
