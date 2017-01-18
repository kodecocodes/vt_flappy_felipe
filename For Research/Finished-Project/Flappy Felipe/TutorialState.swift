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

class TutorialState: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    setupTutorial()
  }
  
  override func willExit(to nextState: GKState) {
    // Remove tutorial
    scene.worldNode.enumerateChildNodes(withName: "Tutorial", using: { node, stop in
      node.run(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.removeFromParent()
        ]))
    })
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is PlayingState.Type
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    
  }
  
  func setupTutorial() {
    scene.setupBackground()
    scene.setupForeground()
    scene.setupPlayer()
    scene.setupScoreLabel()
    
    let tutorial = SKSpriteNode(imageNamed: "Tutorial")
    tutorial.position = CGPoint(x: scene.size.width * 0.5, y: scene.playableHeight * 0.4 + scene.playableStart)
    tutorial.name = "Tutorial"
    tutorial.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(tutorial)
    
    let ready = SKSpriteNode(imageNamed: "Ready")
    ready.position = CGPoint(x: scene.size.width * 0.5, y: scene.playableHeight * 0.7 + scene.playableStart)
    ready.name = "Tutorial"
    ready.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(ready)
    
  }
}
