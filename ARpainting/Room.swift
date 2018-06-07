//
//  Room.swift
//  ARpainting
//
//  Created by 陳奕嘉 on 2018/6/7.
//  Copyright © 2018年 orange. All rights reserved.
//

import Firebase
import FirebaseDatabase
import SceneKit

class Room{
    
    struct line {
        var startPoint: SCNVector3!
        var endPoint: SCNVector3!
    }
    
    private var _roomRef: DatabaseReference!
    
    private var _roomKey: String!
    private var _roomName: String!
    private var _roomPassword: String!
    private var _roomLines: [line]!
    
    var roomRef: DatabaseReference {
        return _roomRef
    }
    
    var roomKey: String {
        return _roomKey
    }
    
    var roomName: String {
        return _roomName
    }
    
    var roomPassword: String {
        return _roomPassword
    }
    
    var roomLines: [line] {
        return _roomLines
    }
    
    init(Key: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._roomKey = Key
        
        if let name = dictionary["roomName"] as? String {
            self._roomName = name
        }
        
        if let password = dictionary["password"] as? String {
            self._roomPassword = password
        }
        
        if let lines = dictionary["lines"] as? [line] {
            self._roomLines = lines
        }else{
            self._roomLines = []
        }
        
        self._roomRef = Database.database().reference().child("rooms").child(self._roomKey)
        
    }
    
    
}
