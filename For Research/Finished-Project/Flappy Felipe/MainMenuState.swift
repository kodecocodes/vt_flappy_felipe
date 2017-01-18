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

class MainMenuState: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    scene.setupBackground()
    scene.setupForeground()
    scene.setupPlayer()
    
    showMainMenu()
    
    scene.player.movementAllowed = false
  }
  
  override func willExit(to nextState: GKState) {
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is TutorialState.Type
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    
  }
  
  func showMainMenu() {
    let logo = SKSpriteNode(imageNamed: "Logo")
    logo.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.8)
    logo.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(logo)
    
    // Play button
    let playButton = SKSpriteNode(imageNamed: "Button")
    playButton.position = CGPoint(x: scene.size.width * 0.25, y: scene.size.height * 0.25)
    playButton.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(playButton)
    
    let play = SKSpriteNode(imageNamed: "Play")
    play.position = CGPoint.zero
    playButton.addChild(play)
    
    // Rate button
    let rateButton = SKSpriteNode(imageNamed: "Button")
    rateButton.position = CGPoint(x: scene.size.width * 0.75, y: scene.size.height * 0.25)
    rateButton.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(rateButton)
    
    let rate = SKSpriteNode(imageNamed: "Rate")
    rate.position = CGPoint.zero
    rateButton.addChild(rate)
    
    // Learn button
    let learn = SKSpriteNode(imageNamed: "button_learn")
    learn.position = CGPoint(x: scene.size.width * 0.5, y: learn.size.height/2 + scene.margin)
    learn.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(learn)
    
    // Bounce button
    let scaleUp = SKAction.scale(to: 1.02, duration: 0.75)
    scaleUp.timingMode = .easeInEaseOut
    let scaleDown = SKAction.scale(to: 0.98, duration: 0.75)
    scaleDown.timingMode = .easeInEaseOut
    
    learn.run(SKAction.repeatForever(SKAction.sequence([
      scaleUp, scaleDown
      ])))
    
    // At the time of this recording, links were not supported so hide the buttons on tvOS
    #if os(tvOS)
      playButton.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
      rateButton.isHidden = true
      learn.isHidden = true
    
      playButton.run(SKAction.repeatForever(SKAction.sequence([
            scaleUp, scaleDown
        ])))
    #endif
  }
}
