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

class GroupBuyCheckOutController: UIViewController, UITextFieldDelegate {
    
    var index = Int()
    var productId = String()
    
    let ref = Database.database().reference()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var couponTextField: UITextField!
    @IBOutlet weak var itemfeeLabel: UILabel!
    @IBOutlet weak var deliverfeeLabel: UILabel!
    @IBOutlet weak var payfeeLabel: UILabel!
    
    @IBOutlet weak var confirmOrderButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        btnAction()
        self.collectionView.reloadData()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "GroupBuyCheckOutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyCheckOutCollectionViewCell")
        
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
        getItemFeeLabel()
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    
    
    func setLabel(value:[String:Any]){
        
        let account = value["account"] as? String
        let name = value["name"] as? String
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String
        let phone = value["phone"] as? String
        
        nameLabel.text = "姓名            " + (name!)
        emailLabel.text = "信箱            " + (account!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
        phoneLabel.text = "手機號碼    " + (phone!)
        
    }
    
    
    func getItemFeeLabel(){
        
        print("in",self.productId)
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let price = value?["Price"] as? String ?? ""
            self.itemfeeLabel.text = price + "元" 
            //       暫定
            self.deliverfeeLabel.text = String(60)
            let payment = Int(price)
            let allPay = (payment ?? 0) as Int + 60
            self.payfeeLabel.text = String(allPay) + "元" 
        })
        
        
    }
    
    
    
    
    
    @IBAction func confirmOrderButtonWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyOrderConfirmControllerId") as!  GroupBuyOrderConfirmController
        let ref =  Database.database().reference().child("GroupBuy").child(productId)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let price = value?["Price"] as? String ?? ""
            let payment = Int(price)
            let allPay = (payment ?? 0) as Int + 60
            vc.payFee = String(allPay) 
            vc.productId = self.productId
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    
    
    
    
}

extension GroupBuyCheckOutController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyCheckOutCollectionViewCell", for: indexPath) as! GroupBuyCheckOutCollectionViewCell
        
        print("self.productId",self.productId)
        cell.setProductLabel(productId: String(self.productId))
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.productId = productId
        self.navigationController?.pushViewController(vc,animated: true)
        
    }
}

extension GroupBuyCheckOutController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.5)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}