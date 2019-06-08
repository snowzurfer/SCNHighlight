//
//  GameViewController.swift
//  SCNHighlight
//
//  Created by Alberto Taiuti on 07/06/2019.
//  Copyright © 2019 Alberto Taiuti. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

fileprivate let highlightMaskValue: Int = 2
fileprivate let normalMaskValue: Int = 1

class GameViewController: UIViewController {
  
  private let scnView = SCNView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Generic stuff
    setupHierarchy()
    setupSCNScene()
    
    // Here we load the technique we'll use to achieve a highlight effect around
    // selected nodes
    if let fileUrl = Bundle.main.url(forResource: "RenderOutlineTechnique", withExtension: "plist"), let data = try? Data(contentsOf: fileUrl) {
      if var result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] { // [String: Any] which ever it is
        
        // Here we update the size and scale factor in the original technique file
        // to whichever size and scale factor the current device is so that
        // we avoid crazy aliasing
        let nativePoints = UIScreen.main.bounds
        let nativeScale = UIScreen.main.nativeScale
        result[keyPath: "targets.MASK.size"] = "\(nativePoints.width)x\(nativePoints.height)"
        result[keyPath: "targets.MASK.scaleFactor"] = nativeScale
        
        guard let technique = SCNTechnique(dictionary: result) else {
          fatalError("This shouldn't be happening! 🤔")
        }

        scnView.technique = technique
      }
    }
    else {
      fatalError("This shouldn't be happening! Has someone been naughty and deleted the file? 🤔")
    }
  }
  
  // Tap to set/unset the highlight
  @objc private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let hitResults = scnView.hitTest(p, options: [:])

    // check that we clicked on at least one object
    guard let first = hitResults.first else {
      return
    }
    
    // Highlight it / remove highlight
    if first.node.categoryBitMask == highlightMaskValue {
      first.node.setCategoryBitMaskForAllHierarchy(normalMaskValue)
    }
    else if first.node.categoryBitMask == normalMaskValue {
      first.node.setCategoryBitMaskForAllHierarchy(highlightMaskValue)
    }
    else {
      fatalError("Unsupported category bit mask value")
    }
  }
    
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }

}

extension GameViewController {
  
  private func setupHierarchy() {
    dispatchPrecondition(condition: .onQueue(.main))

    scnView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scnView)
    scnView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    scnView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scnView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    scnView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    // add a tap gesture recognizer
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    scnView.addGestureRecognizer(tapGesture)
  }
  
  private func setupSCNScene() {
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.simdPosition.z = 15
    
    // create and add a light to the scene
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.simdPosition = simd_float3(0, 10, 10)
    scene.rootNode.addChildNode(lightNode)
    
    // create and add an ambient light to the scene
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)
    
    // retrieve the ship node
    let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
    
    // animate the 3d object
    ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
    
    // Set its highlight
    ship.setCategoryBitMaskForAllHierarchy(highlightMaskValue)
    
    // set the scene to the view
    scnView.scene = scene
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = true
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = true
    
    // configure the view
    scnView.backgroundColor = UIColor.black
  }
}
