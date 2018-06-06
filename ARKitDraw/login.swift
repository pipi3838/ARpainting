//
//  login.swift
//  ARKitDraw
//
//  Created by 吳柏承 on 2018/6/6.
//  Copyright © 2018年 Felix Lapalme. All rights reserved.
//

import UIKit
import Firebase

class login: UIViewController ,UITextFieldDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.account.delegate = self
        self.password.delegate = self

    }
    struct user{
        var name: String
        var password: String
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    struct userAccount{
        var account: String
        var password: String
    }
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func RegisterAndDraw(_ sender: Any) {
        let User = account.text!
        let databaseRef = Database.database().reference()
        databaseRef.child("Users").childByAutoId().setValue(User)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        password.resignFirstResponder()
        account.resignFirstResponder()
        return true
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
