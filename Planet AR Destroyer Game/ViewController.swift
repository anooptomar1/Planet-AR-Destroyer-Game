//
//  ViewController.swift
//  Planet AR Destroyer Game
//
//  Created by Orion Choy on 5/7/18.
//  Copyright © 2018 Orion Choy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

enum BoxBodyType : Int {
    case bullet = 1
    case barrier = 2
}



class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate  {
    
    
   
    @IBOutlet var sceneView: ARSCNView!
    var player:AVAudioPlayer = AVAudioPlayer()
    var lastContactNode :SCNNode!
    var Target: SCNNode?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do{
            let audioPath = Bundle.main.path(forResource: "01_Title Screen", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }catch{
            
            
        }
        player.play()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        
        
        
        
        
        
        
        let planet1 = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        
        planet1.materials = [material]
        
        let planet2 = SCNSphere(radius: 0.1)
        let material2 = SCNMaterial()
        material2.diffuse.contents = UIColor.green
        planet2.materials = [material2]
        
        let planet3 = SCNSphere(radius:0.1)
        let material3 = SCNMaterial()
        material3.diffuse.contents = UIColor.yellow
        
        planet3.materials = [material3]
        
        
        
        let planet1Node = SCNNode(geometry: planet1)
        planet1Node.name = "Barrier1"
        planet1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet1Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        
        let planet2Node = SCNNode(geometry: planet2)
        planet2Node.name = "Barrier2"
        planet2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet2Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        
        let planet3Node = SCNNode(geometry: planet3)
        planet3Node.name = "Barrier3"
        planet3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet3Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        planet1Node.position = SCNVector3(0,0,-1.0)
        planet2Node.position = SCNVector3(-0.8,-0.2,-3.0)
        planet3Node.position = SCNVector3(0.8,0.2,-2.0)
        
        
        scene.rootNode.addChildNode(planet1Node)
        scene.rootNode.addChildNode(planet2Node)
        scene.rootNode.addChildNode(planet3Node)
        
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        registerGestureRecognizers()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        
        
        
        var contactNode :SCNNode!
        
        if nodeA.name == "Bullet" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if self.lastContactNode != nil && self.lastContactNode == contactNode {
            return
        }
        
        self.lastContactNode = contactNode
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        self.lastContactNode.geometry?.materials = [material]
        
        contact.nodeB.removeFromParentNode()
        
        
        
        
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func shoot(recognizer :UIGestureRecognizer) {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        
        let box = SCNBox(width: 0.03, height: 0.03, length: 0.03, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Bullet"
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
        boxNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        boxNode.physicsBody?.isAffectedByGravity = false
        
        boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let forceVector = SCNVector3(boxNode.worldFront.x * 8,boxNode.worldFront.y * 8,boxNode.worldFront.z * 8)
        
        boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
}

