//
//  CheckoutController.swift
//  vip
//
//  Created by Chun on 2020/4/1.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class CheckoutController: UIViewController {
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var itemFeeLabel: UILabel!
    @IBOutlet weak var deliverFeeLabel: UILabel!
    @IBOutlet weak var payFeeLabel: UILabel!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
            .child("Profile")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String:Any]
                    else {
                        print("Error")
                        return
                }
                self.setLabel(value: value)
            })
    }
    
    func setLabel(value:[String:Any]){

        let account = value["account"] as? String
        let name = value["name"] as? String
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String
        if (value["phone"] as? String) == nil{
            print("phone is null ")
            phoneLabel.text = "請設定手機號碼"
            phoneLabel.textColor = UIColor(red: 255/255, green: 136/255, blue: 128/255, alpha: 1)
               }else{
                   let phone = value["phone"] as? String
                   phoneLabel.text = "手機號碼    " + (phone!)
               }
        nameLabel.text = "姓名            " + (name!)
        emailLabel.text = "信箱            " + (account!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
    }
    
    func transitionToLogInScene(){
        let storyboard = UIStoryboard(name: "SignUpLogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInControllerId") as! LogInController
        self.navigationController?.pushViewController(vc,animated: true)
    }
}
