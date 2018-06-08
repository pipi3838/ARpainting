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
    
    private var _roomRef: DatabaseReference!
    
    private var _roomKey: String!
    private var _roomName: String!
    private var _roomPassword: String!
    
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
    
    init(Key: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._roomKey = Key
        
        if let name = dictionary["roomName"] as? String {
            self._roomName = name
        }
        
        if let password = dictionary["password"] as? String {
            self._roomPassword = password
        }
        
        self._roomRef = Database.database().reference().child("rooms").child(self._roomKey)
        
    }
    
    
}
