//
//  ViewController.swift
//  AR Dice
//
//  Created by Randy Hsu on 2019-02-08.
//  Copyright © 2019 DeveloperRandy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    //MARK: - Touch Delegate 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.sceneView)
            let hitTestResults = self.sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = hitTestResults.first {
                self.addDice(at: hitResult)
            }
            
        }
    }
    
    //MARK: -
    func addDice(at hitResult: ARHitTestResult) {
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let node = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            node.position = SCNVector3(
                hitResult.worldTransform.columns.3.x
                ,hitResult.worldTransform.columns.3.y + (node.boundingSphere.radius*5)
                ,hitResult.worldTransform.columns.3.z)
            
            self.diceArray.append(node)
            self.sceneView.scene.rootNode.addChildNode(node)
            self.runRollingDiceAction(node: node)
        }
    }
    
    func runRollingDiceAction(node: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        node.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5), duration: 0.5))
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        
        for dice in self.diceArray {
            dice.removeFromParentNode()
        }
        self.diceArray.removeAll()
    }
    
    //MARK: - ARSCNView Delegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
    
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
    
            let grindMaterial = SCNMaterial()
            grindMaterial.diffuse.contents = UIColor(displayP3Red: 0.7, green: 0.75, blue: 0.76, alpha: 0.5)
    
            plane.materials = [grindMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
    
        }
}
