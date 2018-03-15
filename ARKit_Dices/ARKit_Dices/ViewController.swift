//
//  ViewController.swift
//  ARKit_Dices
//
//  Created by Maximilian Dufter on 10.03.18.
//  Copyright © 2018 Maximilian Dufter. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // Needed to spin alles dices at once
    var dices = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Box
        // 20 cm
//        let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.01)
        
        // Mars textures from
        // https://www.solarsystemscope.com
//        let sphere = SCNSphere(radius: 0.2)
        
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.blue
//        material.diffuse.contents = UIImage(named: "art.scnassets/mars.jpg")
        
//        cube.materials = [material]
//        sphere.materials = [material]
        
        // position in space
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = cube
//        node.geometry = sphere
        
        
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        // recursively: include subtrees
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D Touch location to 3D point
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // Check if plane was touched
            if let hit = results.first {
                
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                
                if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    // Place cube on touched position
                    diceNode.position = SCNVector3(
                        x: hit.worldTransform.columns.3.x,
                        y: hit.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hit.worldTransform.columns.3.z
                    )
                    
                    dices.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    // Give plane width and height
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Is the anchor a plane
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            // PlaneAnchor is always two dimensional
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            // Vertical by default. Needs to be rotated
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
        
    }
    
    func rollDices() {
        if !dices.isEmpty {
            for dice in dices {
                roll(dice: dice)
            }
        }
    }
    @IBAction func reloadDices(_ sender: UIBarButtonItem) {
        
        if !dices.isEmpty {
            for dice in dices {
                dice.removeFromParentNode()
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollDices()
    }
    
    // Roll again if shake
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollDices()
    }
    
    func roll(dice: SCNNode) {
        // Rotation around the Y axis is not needed
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 10),
            y: 0,
            z: CGFloat(randomZ  * 10),
            duration: 1))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
