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
}

class GameScene: SKScene {

  let worldNode = SKNode()
  var playableStart: CGFloat = 0
  var playableHeight: CGFloat = 0

  let numberOfForegrounds = 2
  let groundSpeed: CGFloat = 150

  let bottomObstacleMinFraction: CGFloat = 0.1
  let bottomObstacleMaxFraction: CGFloat = 0.6
  let gapMultiplier: CGFloat = 4.5 // the higher the number, the easier the game

  let firstSpawnDelay: TimeInterval = 1.75
  let everySpawnDelay: TimeInterval = 1.5

  var deltaTime: TimeInterval = 0
  var lastUpdateTimeInterval: TimeInterval = 0

  let player = PlayerEntity(imageName: "Bird0")

  override func didMove(to view: SKView) {
    addChild(worldNode)
    setupBackground()
    setupForeground()
    setupPlayer()
    // spawnObstacle()
    startSpawning()
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
    for i in 0..<numberOfForegrounds {
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
  }

  func createObstacle() -> SKSpriteNode {
    let obstacle = ObstacleEntity(imageName: "Cactus")
    let obstacleNode = obstacle.spriteComponent.node
    obstacleNode.zPosition = Layer.obstacle.rawValue

    return obstacle.spriteComponent.node
  }

  func startSpawning() {
    let firstDelay = SKAction.wait(forDuration: firstSpawnDelay)
    let spawn = SKAction.run(spawnObstacle)
    let everyDelay = SKAction.wait(forDuration: everySpawnDelay)

    let spawnSequence = SKAction.sequence([spawn, everyDelay])
    let foreverSpawn = SKAction.repeatForever(spawnSequence)
    let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])

    run(overallSequence)
  }

  func spawnObstacle() {
    // Bottom Obstacle
    let bottomObstacle = createObstacle()
    let startX = size.width + bottomObstacle.size.width / 2

    let bottomObstacleMin = (playableStart - bottomObstacle.size.height / 2) + playableHeight * bottomObstacleMinFraction
    let bottomObstacleMax = (playableStart - bottomObstacle.size.height / 2) + playableHeight * bottomObstacleMaxFraction

    // let randomValue = CGFloat.random(bottomObstacleMin, max: bottomObstacleMax)

    // Using GameplayKit's randomization
    let randomSource = GKARC4RandomSource()
    let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(bottomObstacleMin)), highestValue: Int(round(bottomObstacleMax)))
    let randomValue = randomDistribution.nextInt()

    bottomObstacle.position = CGPoint(x: startX, y: CGFloat(randomValue))
    worldNode.addChild(bottomObstacle)

    // Top Obstacle
    let topObstacle = createObstacle()
    topObstacle.zRotation = CGFloat(180).degreesToRadians()
    topObstacle.position = CGPoint(x: startX, y: bottomObstacle.position.y + bottomObstacle.size.height / 2 + topObstacle.size.height / 2 + player.spriteComponent.node.size.height * gapMultiplier)
    worldNode.addChild(topObstacle)

    // Move Obstacles
    let moveX = size.width + topObstacle.size.width
    let moveDuration = moveX / groundSpeed

    let sequence = SKAction.sequence([
      SKAction.moveBy(x: -moveX, y: 0, duration: TimeInterval(moveDuration)),
      SKAction.removeFromParent()
      ])

    topObstacle.run(sequence)
    bottomObstacle.run(sequence)
  }

  func updateForeground() {
    worldNode.enumerateChildNodes(withName: "foreground", using:
      { node, stop in
        if let foreground = node as? SKSpriteNode {
          let moveAmount = CGPoint(x: -self.groundSpeed * CGFloat(self.deltaTime),
                                   y: 0)
          foreground.position += moveAmount

          if foreground.position.x < -foreground.size.width {
            foreground.position += CGPoint(x: foreground.size.width * CGFloat(self.numberOfForegrounds), y: 0)
          }
        }
    })
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.movementComponent.applyImpulse(lastUpdateTimeInterval)
  }

  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTimeInterval == 0 {
      lastUpdateTimeInterval = currentTime
    }

    deltaTime = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    
    updateForeground()
    
    player.update(deltaTime: deltaTime)
  }
}
