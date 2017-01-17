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

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate {
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if let skView = self.view as? SKView {
      if skView.scene == nil {
        
        // Create the scene
        let aspectRatio  = skView.bounds.size.height / skView.bounds.size.width
        let scene = GameScene(size:CGSize(width: 320, height: 320 * aspectRatio), stateClass: MainMenuState.self, delegate: self)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = false
        
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
      }
    }
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  func screenshot() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  func shareString(_ string: String, url: URL, image: UIImage) {
    let vc = UIActivityViewController(activityItems: [string, url, image], applicationActivities: nil)
    present(vc, animated: true, completion: nil)
  }
  
}
