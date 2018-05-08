// Orion Choy
// Final Project
// SUNY Ulster
//
//
//
//
//  Created by Orion Choy on 5/6/18.
//  Copyright © 2018 Orion Choy. All rights reserved.

import UIKit
import SceneKit
import ARKit
import AVFoundation



enum ShapeBodyType : Int {
    case laserbeam = 1
    case planet = 2
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate  {
   
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    var player:AVAudioPlayer = AVAudioPlayer()
    var lastContactNode :SCNNode!
    var Target: SCNNode?
    var timeCounter: Float = 0
    var countingtimeBool = false
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //play background music in background music folder
        do{
            let audioPath = Bundle.main.path(forResource: "01_Title Screen", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }catch{
        }
        player.play()
        

        //Add timer and update label with time elapsed
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (ViewController.startAction), userInfo: nil, repeats: true)
        timeCounter += 1
        timeLabel.text = String(timeCounter)
        
       
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        
        
        //Create 3 planets of type SCNSphere
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
        
        
        
        //Create nodes for each planet
        let planet1Node = SCNNode(geometry: planet1)
        planet1Node.name = "Planet1"
        planet1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet1Node.physicsBody?.categoryBitMask = ShapeBodyType.planet.rawValue
        
        let planet2Node = SCNNode(geometry: planet2)
        planet2Node.name = "Planet2"
        planet2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet2Node.physicsBody?.categoryBitMask = ShapeBodyType.planet.rawValue
        
        let planet3Node = SCNNode(geometry: planet3)
        planet3Node.name = "Planet3"
        planet3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        planet3Node.physicsBody?.categoryBitMask = ShapeBodyType.planet.rawValue
        
        
        //Place planets in 3D space using SCNVector
        planet1Node.position = SCNVector3(0.5,0,-4.0)
        planet2Node.position = SCNVector3(-0.8,-0.2,-3.0)
        planet3Node.position = SCNVector3(0.8,0.2,-2.0)
        
        
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //add each planetNode to scene
        scene.rootNode.addChildNode(planet1Node)
        scene.rootNode.addChildNode(planet2Node)
        scene.rootNode.addChildNode(planet3Node)
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        registerGestureRecognizers()
    }
    
    
    //Function to define rules if laser beam comes in contact with Planet
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        
        var contactNode :SCNNode!
        
        if nodeA.name == "Laser" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if self.lastContactNode != nil && self.lastContactNode == contactNode {
            return
        }
        
        
        //If laser beam comes in contact with planet, planet will change colors and disappear
        
        self.lastContactNode = contactNode
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        self.lastContactNode.geometry?.materials = [material]

        //Removes node from view
        contactNode.removeFromParentNode()
        
    }
    
    
    // When user taps the screen, fire laser beam projectile
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fireshot))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func fireshot(recognizer :UIGestureRecognizer) {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        
        
        
        
        //Creates dimensions and attributes of laser beam
        
        let laserBeam = SCNBox(width: 0.02, height: 0.02, length: 0.04, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        
        let laserNode = SCNNode(geometry: laserBeam)
        laserNode.name = "Laser"
        laserNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        laserNode.physicsBody?.categoryBitMask = ShapeBodyType.laserbeam.rawValue
        laserNode.physicsBody?.contactTestBitMask = ShapeBodyType.planet.rawValue
        laserNode.physicsBody?.isAffectedByGravity = false
        
        laserNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        //Defines speed with which laser beam shoots and interacts with planets
        let forceVector = SCNVector3(laserNode.worldFront.x * 6,laserNode.worldFront.y * 6,laserNode.worldFront.z * 6)
        
        laserNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(laserNode)
    }
    
    
    //Part of timer functionality, updates label with time elapsed
    @objc func startAction(){
        timeCounter += 1
        timeLabel.text = "Time Played: " + String(timeCounter)
        
    }

    //Exit game if tapped
    @IBAction func ExitButton(_ sender: UIButton) {
     exit(0)
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
