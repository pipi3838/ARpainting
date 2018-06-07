//
//  ViewController.swift
//  ARKitDraw
//
//  Created by Felix Lapalme on 2017-06-07.
//  Copyright © 2017 Felix Lapalme. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import FirebaseDatabase

class PaintViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    struct line {
        var startPoint: SCNVector3!
        var endPoint: SCNVector3!
        
        init(start: SCNVector3, end: SCNVector3){
            self.startPoint = start
            self.endPoint = end
        }
    }
    
    struct chat {
        var owner: String!
        var text: String!
        
        init(owner: String, text:String) {
            self.owner = owner
            self.text = text
        }
        
    }

    @IBOutlet weak var sceneView: ARSCNView!
    var previousPoint: SCNVector3?
    @IBOutlet weak var drawButton: UIButton!
    var lineColor = UIColor.white
    
    var buttonHighlighted = false
    
    var linesRef: DatabaseReference!
    var lines = [String:line]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    var chatsRef: DatabaseReference!
    var chats = [chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        linesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let lineDict = snap.value as? [String : AnyObject]{
                        let key = snap.key
                        
                        let startArr = lineDict["start"] as! [Double]
                        let endArr = lineDict["end"] as! [Double]
                        
                        let startPoint = SCNVector3(startArr[0], startArr[1], startArr[2])
                        let endPoint = SCNVector3(endArr[0], endArr[1], endArr[2])
                        
                        let myLine = line(start: startPoint, end: endPoint)
                        
                        self.lines[key] = myLine
                        self.addLineToRootNode(start: startPoint, end: endPoint)
                        
                    }
                }
            }
            
        })
        
        
        /*
        linesRef.observe(DataEventType.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    let key = snap.key
                    if self.lines[key] != nil{
                        if let lineDict = snap.value as? [String : AnyObject]{
                            
                            let startArr = lineDict["start"] as! [Double]
                            let endArr = lineDict["end"] as! [Double]
                            
                            let startPoint = SCNVector3(startArr[0], startArr[1], startArr[2])
                            let endPoint = SCNVector3(endArr[0], endArr[1], endArr[2])
                            
                            var myLine = line(start: startPoint, end: endPoint)
                            
                            self.lines[key] = myLine
                            self.addLineToRootNode(start: startPoint, end: endPoint)
                            
                        }
                    }
                }
            }
            
        })
        */
        
        tableView.backgroundColor = .clear
        
        chatsRef.observe(DataEventType.value, with: { (snapshot) in
            
            self.chats = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let lineDict = snap.value as? [String : AnyObject]{
                        let ownerString = lineDict["owner"] as! String
                        let textString = lineDict["text"] as! String
                        
                        let myChat = chat(owner: ownerString, text: textString)
                        self.chats.append(myChat)
                        
                    }
                }
            }
            
            self.tableView.reloadData()
            if self.chats.count > 0{
                self.tableView.scrollToRow(at: IndexPath(item:self.chats.count-1, section: 0), at: .bottom, animated: true)
            }
            
            
        })
        
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.buttonHighlighted = self.drawButton.isHighlighted
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
        
        if buttonHighlighted {
            if let previousPoint = previousPoint {
                addLineToRootNode(start: previousPoint, end: currentPosition)
                addLineToDatabase(start: previousPoint, end: currentPosition)
                
            }
        }
        previousPoint = currentPosition
        glLineWidth(20)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    func addLineToRootNode(start: SCNVector3, end: SCNVector3){
        let line = lineFrom(vector: start, toVector: end)
        let lineNode = SCNNode(geometry: line)
        lineNode.geometry?.firstMaterial?.diffuse.contents = lineColor
        sceneView.scene.rootNode.addChildNode(lineNode)
        
        
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    func addLineToDatabase(start: SCNVector3, end: SCNVector3){
        let startPoint = [start.x, start.y, start.z]
        let endPoint = [end.x, end.y, end.z]
        
        let newLine = linesRef.childByAutoId()
        self.lines[newLine.key] = line(start: start, end: end)
        newLine.setValue(["start":startPoint, "end":endPoint])
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        if messageTextField.text != "" {
            chatsRef.childByAutoId().setValue(["owner":"Me", "text": messageTextField.text!])
            messageTextField.text = ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = chats[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "\(chat.owner!) said \(chat.text!)"
        cell.backgroundColor = tableView.backgroundColor
        cell.contentView.backgroundColor = tableView.backgroundColor
        
        // Configure the cell...
        
        return cell
    }
    
}
