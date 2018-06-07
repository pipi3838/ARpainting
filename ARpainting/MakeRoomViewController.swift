//
//  MakeRoomViewController.swift
//  ARpainting
//
//  Created by 陳奕嘉 on 2018/6/7.
//  Copyright © 2018年 orange. All rights reserved.
//

import UIKit
import Firebase

class MakeRoomViewController: UIViewController {
    
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MakeRoom(_ sender: Any) {
        
        let roomName = roomNameTextField.text
        let roomPassword = passwordTextField.text
        
        if roomName != nil && roomPassword != nil {
            
            let roomsRef = Database.database().reference().child("rooms")
            roomsRef.childByAutoId().setValue(["roomName":roomName, "password":roomPassword])
            
            let alertController = UIAlertController(title: "Congratulation", message: "Success to make a room", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:
            {(alert: UIAlertAction!) in
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            })
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
