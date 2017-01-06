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
  case obstacle
  case foreground
  case player
  case ui
  case flash
}

struct PhysicsCategory {
  static let None: UInt32 =       0     // 0
  static let Player: UInt32 =     0b1   // 1
  static let Obstacle: UInt32 =   0b10  // 2
  static let Ground: UInt32 =     0b100 // 4
}

protocol GameSceneDelegate {
  func screenshot() -> UIImage
  func shareString(_ string: String, url: URL, image: UIImage)
}

protocol TVControlsScene {
    func setupTVControls()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var gameSceneDelegate: GameSceneDelegate
  let appStoreLink = "https://itunes.apple.com/us/app/flappy-felipe/id820464950?mt=8"
  
  let worldNode = SKNode()
  
  var playableStart: CGFloat = 0
  var playableHeight: CGFloat = 0
  
  var numberOfForegrounds = 2
  let groundSpeed: CGFloat = 150
  
  var deltaTime: TimeInterval = 0
  var lastUpdateTimeInterval: TimeInterval = 0
  
  let player = Player(imageName: "Bird0")
  
  let bottomObstacleMinFraction: CGFloat = 0.1
  let bottomObstacleMaxFraction: CGFloat = 0.6
  
  let gapMultiplier: CGFloat = 3.5
  
  let firstSpawnDelay: TimeInterval = 1.75
  let everySpawnDelay: TimeInterval = 1.5
  
  lazy var gameState: GKStateMachine = GKStateMachine(states: [
    MainMenuState(scene: self),
    TutorialState(scene: self),
    PlayingState(scene: self),
    FallingState(scene: self),
    GameOverState(scene: self)
    ])
  
  var scoreLabel: SKLabelNode!
  var score = 0
  
  var fontName = "AmericanTypewriter-Bold"
  var margin: CGFloat = 20.0
  
  let popAction = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
  let coinAction = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
  
  var initialState: AnyClass
  
  init(size: CGSize, stateClass: AnyClass, delegate: GameSceneDelegate) {
    gameSceneDelegate = delegate
    initialState = stateClass
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    addChild(worldNode)
    // setupBackground()
    // setupForeground()
    // setupPlayer()
    // setupScoreLabel()
    
    // startSpawning()
    // gameState.enterState(PlayingState)
    gameState.enter(initialState)
    
    let scene = (self as SKScene)
    if let scene = scene as? TVControlsScene {
        scene.setupTVControls()
    }
  }
  
  // MARK: Setup methods
  
  func setupBackground() {
    
    let background = SKSpriteNode(imageNamed: "Background")
    let numberOfSprites = Int(size.width / background.size.width) + 1
    
    for i in 0..<numberOfSprites {
      let background = SKSpriteNode(imageNamed: "Background")
      background.anchorPoint = CGPoint(x: 0.0, y: 1.0)
      background.position = CGPoint(x: CGFloat(i) * background.size.width + 1, y: size.height)
        background.zPosition = Layer.background.rawValue
        background.name = "background"
      
        worldNode.addChild(background)
    }
    
    playableStart = size.height - background.size.height
    playableHeight = background.size.height
    
    let lowerLeft = CGPoint(x: 0, y: playableStart)
    let lowerRight = CGPoint(x: size.width, y: playableStart)
    
    // Add physics
    physicsBody = SKPhysicsBody(edgeFrom: lowerLeft, to: lowerRight)
    physicsBody?.categoryBitMask = PhysicsCategory.Ground
    physicsBody?.collisionBitMask = 0
    physicsBody?.contactTestBitMask = PhysicsCategory.Player
  }
  
  func setupForeground() {
    let foreground = SKSpriteNode(imageNamed: "Ground")
    let numberOfSprites = Int(size.width / foreground.size.width) + 2
    
    numberOfForegrounds = numberOfSprites
    
    for i in 0..<numberOfSprites {
      let foreground = SKSpriteNode(imageNamed: "Ground")
      foreground.anchorPoint = CGPoint(x: 0.0, y: 1.0)
      foreground.position = CGPoint(x: CGFloat(i) * foreground.size.width, y: playableStart)
        foreground.zPosition = Layer.foreground.rawValue
        foreground.name = "foreground"
      
        worldNode.addChild(foreground)
    }
  }
  
  func setupPlayer() {
    let playerNode = player.spriteComponent.node
    playerNode.position = CGPoint(x: size.width * 0.2, y: playableHeight * 0.4 + playableStart)
    playerNode.zPosition = Layer.player.rawValue
    
    worldNode.addChild(playerNode)
    
    player.movementComponent.playableStart = playableStart
    
    player.animationComponent.startWobble()
  }
  
  func setupScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: fontName)
    scoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    scoreLabel.position = CGPoint(x: size.width/2, y: size.height - margin)
    scoreLabel.verticalAlignmentMode = .top
    scoreLabel.zPosition = Layer.ui.rawValue
    
    scoreLabel.text = "\(score)"
    
    worldNode.addChild(scoreLabel)
  }
  
  // MARK: Obstacle methods
  
  func startSpawning() {
    let firstDelay = SKAction.wait(forDuration: firstSpawnDelay)
    let spawn = SKAction.run(spawnObstacle)
    let everyDelay = SKAction.wait(forDuration: everySpawnDelay)
    
    let spawnSequence = SKAction.sequence([spawn, everyDelay])
    let foreverSpawn = SKAction.repeatForever(spawnSequence)
    let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])
    
    // runAction(overallSequence)
    run(overallSequence, withKey: "spawn")
  }
  
  func stopSpawning() {
    removeAction(forKey: "spawn")
    worldNode.enumerateChildNodes(withName: "obstacle", using: {node, stop in
      node.removeAllActions()
    })
  }
  
  func createObstacle() -> SKSpriteNode {
    let obstacle = Obstacle(imageName: "Cactus")
    let obstacleNode = obstacle.spriteComponent.node
    obstacleNode.zPosition = Layer.obstacle.rawValue
    
    obstacleNode.name = "obstacle"
    obstacleNode.userData = NSMutableDictionary()
    
    return obstacle.spriteComponent.node
  }
  
  func spawnObstacle() {
    
    // Bottom obstacle
    let bottomObstacle = createObstacle()
    let startX = size.width + bottomObstacle.size.width/2
    
    let bottomObstacleMin = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMinFraction
    let bottomObstacleMax = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMaxFraction
    
    // let randomValue = CGFloat.random(min: bottomObstacleMin, max: bottomObstacleMax)
    
    // Using GameplayKit's randomization
    let randomSource = GKARC4RandomSource()
    let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(bottomObstacleMin)), highestValue: Int(round(bottomObstacleMax)))
    let randomValue = randomDistribution.nextInt()
    
    bottomObstacle.position = CGPoint(x: startX, y: CGFloat(randomValue))
    worldNode.addChild(bottomObstacle)
    
    // Top obstacle
    let topObstacle = createObstacle()
    topObstacle.zRotation = CGFloat(180).degreesToRadians()
    topObstacle.position = CGPoint(x: startX, y: bottomObstacle.position.y + bottomObstacle.size.height/2 + topObstacle.size.height/2 + player.spriteComponent.node.size.height * gapMultiplier)
    worldNode.addChild(topObstacle)
    
    let moveX = size.width + topObstacle.size.width
    let moveDuration = moveX / groundSpeed
    
    let sequence = SKAction.sequence([
      SKAction.moveBy(x: -moveX, y: 0, duration: TimeInterval(moveDuration)),
      SKAction.removeFromParent()
      ])
    
    topObstacle.run(sequence)
    bottomObstacle.run(sequence)
  }
  
  // MARK: Game Play
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    #if os(iOS)
    if let touch = touches.first{
      let touchLocation = touch.location(in: self)
      
      switch gameState.currentState {
      case is MainMenuState:
        if touchLocation.y < size.height * 0.15 {
          learn()
        } else if touchLocation.x < size.width * 0.6 {
          restartGame(TutorialState.self)
        } else {
          rateApp()
        }
      case is TutorialState:
        gameState.enter(PlayingState.self)
      case is PlayingState:
        player.movementComponent.applyImpulse(lastUpdateTimeInterval)
      case is GameOverState:
        if touchLocation.x < size.width * 0.6 {
          restartGame(TutorialState.self)
        } else {
          shareScore()
        }
      default:
        break
      }
    }
    #endif
  }
  
  func restartGame(_ stateClass: AnyClass) {
    run(popAction)
    
    let newScene = GameScene(size: size, stateClass: stateClass, delegate: gameSceneDelegate)
    let transition = SKTransition.fade(with: SKColor.black, duration: 0.02)
    view?.presentScene(newScene, transition: transition)
  }
  
  // MARK: Physics
  
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
    
    if other.categoryBitMask == PhysicsCategory.Ground {
      // print("hit ground")
      gameState.enter(GameOverState.self)
    }
    if other.categoryBitMask == PhysicsCategory.Obstacle {
      // print("hit obstacle")
      gameState.enter(FallingState.self)
    }
  }
  
  // MARK: Updates
  
  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTimeInterval == 0 {
      lastUpdateTimeInterval = currentTime
    }
    
    deltaTime = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    
    // Begin updates
    // updateForeground()
    gameState.update(deltaTime: deltaTime)
    
    // Per-Entity updates
    player.update(deltaTime: deltaTime)
  }
  
  func updateScore() {
    worldNode.enumerateChildNodes(withName: "obstacle", using: {node, stop in
      if let obstacle = node as? SKSpriteNode {
        if let passed = obstacle.userData?["Passed"] as? NSNumber {
          if passed.boolValue {
            return
          }
        }
        if self.player.spriteComponent.node.position.x > obstacle.position.x + obstacle.size.width/2 {
          self.score += 1
          self.scoreLabel.text = "\(self.score/2)"
          
          obstacle.userData?["Passed"] = NSNumber(value: true as Bool)
          self.run(self.coinAction)
        }
      }
    })
  }
  
  func updateForeground() {
    worldNode.enumerateChildNodes(withName: "foreground", using: { node, stop in
      if let foreground = node as? SKSpriteNode {
        let moveAmount = CGPoint(x: -self.groundSpeed * CGFloat(self.deltaTime), y: 0)
        foreground.position += moveAmount
        
        if foreground.position.x < -foreground.size.width {
          foreground.position += CGPoint(x: foreground.size.width * CGFloat(self.numberOfForegrounds), y: 0)
        }
      }
    })
  }
  
  // MARK: Extras
  func shareScore() {
    let urlString = appStoreLink
    let url = URL(string: urlString)
    
    let screenshot = gameSceneDelegate.screenshot()
    let initialTextString = "OMG! I scored \(score/2) points in Flappy Felipe!"
    gameSceneDelegate.shareString(initialTextString, url: url!, image: screenshot)
  }
  
  func rateApp() {
    let urlString = appStoreLink
    let url = URL(string: urlString)
    if #available(tvOS 10.0, *) {
      UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    } else {
      // Fallback on earlier versions
    }
  }
  
  func learn() {
    let urlString = "http://www.raywenderlich.com/flappy-felipe"
    let url = URL(string: urlString)
    if #available(tvOS 10.0, *) {
      UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    } else {
      // Fallback on earlier versions
    }
  }
}
