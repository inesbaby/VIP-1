//
//  GroupBuyOrderConfirmController.swift
//  vip
//
//  Created by Ines on 2020/4/7.
//  Copyright © 2020 Ines. All rights reserved.


import UIKit
import Firebase


class GroupBuyOrderConfirmController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var payfeeLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var checkButton: UIButton!
    
    var index = Int()
    var productIndex = Int()
    var productId = String()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var payFee = ""
    let ref =  Database.database().reference().child("GroupBuy")
    let refUserGroupBuy =  Database.database().reference().child("UserGroupBuy")
    var uid = Auth.auth().currentUser?.uid
    var groupBuyStyle = String()
    var groupBuyPeople = Int()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        userInfo()
        print("groupBuyStyle",groupBuyStyle)
        print("groupBuyPeople",groupBuyPeople)
        
    }
    
    
    @IBAction func callservice(_ sender: Any) {
        if let callURL:URL = URL(string: "tel:\(+886961192398)") {
            
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(callURL)) {
                let alert = UIAlertController(title: "撥打客服專線", message: "", preferredStyle: .alert)
                let callAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                    application.openURL(callURL)
                })
                let noAction = UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                    print("Canceled Call")
                })
                
                alert.addAction(callAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func userInfo(){
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
        
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String           
        payfeeLabel.text = "付款總金額    " + (payFee) + "元"
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        
    }
    
    
    
    func collectionViewDeclare(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "OrderComfirmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderComfirmCollectionViewCell")
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    
    //   加入資料庫 成立訂單
    @IBAction func checkButtonWasPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCehckFinalControllerId") as!  GroupBuyCehckFinalController
        
        if groupBuyStyle == "Open" {
            open(vc:vc)
            print("Open")
        }
        
        if groupBuyStyle == "Join" {
            join(vc:vc)
            print("Join")
        }
        
    }
    
    func open(vc:GroupBuyCehckFinalController){
        
        ref.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let openGroupRef = self.ref.child(self.productId).child("OpenGroupId").childByAutoId()
            openGroupRef.child("OpenBy").child(self.uid ?? "").setValue(self.uid ?? "")
            openGroupRef.child("JoinBy").child(self.uid ?? "").setValue(self.uid ?? "")
            openGroupRef.child("Status").setValue("Waiting")
            openGroupRef.child("GroupCreateTime").setValue(self.getTime())
            
            
            
            self.ref.child(self.productId).child("OpenGroupId").queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                snapshot in
                
                
                let refOrder = Database.database().reference().child("GroupBuyOrder").childByAutoId()
                let orderId = refOrder.key
                
                Database.database().reference(withPath: "UserGroupBuy/\(self.uid ?? "wrong message : no currentUser")/OrderId/\(orderId ?? "")/ProductId/").setValue(self.productId)
                
                
                vc.orderAutoId = orderId ?? ""
                vc.openId = openGroupRef.key ?? ""
                refOrder.child("OpenGroupId").setValue(openGroupRef.key ?? "")
                refOrder.child("Payment").setValue(self.payFee)
                refOrder.child("OrderCreateTime").setValue(self.getTime())
                refOrder.child("Comment").setValue("false")
                
                
                let value = snapshot.value as? NSDictionary
                let price = value?["Price"] as? String ?? ""
                let payment = Int(price)
                let allPay = (payment ?? 0) as Int + 60
                vc.payFee = String(allPay) 
                vc.productId = self.productId
                vc.index = self.index
                vc.productIndex = self.productIndex
                vc.groupBuyStyle = self.groupBuyStyle
                vc.groupBuyPeople = self.groupBuyPeople
                
                let message = UIAlertController(title: "結帳成功", message: nil, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
                {action in
                    print("checkout success")
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                message.addAction(confirmAction)
                self.present(message, animated: true, completion: nil)
                
            })
            
            
        })
        
        
        
    }
    
    
    func join(vc:GroupBuyCehckFinalController) {
        
        let refs = ref.child(productId).child("OpenGroupId")
        
        refs.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print("snapshots[self.index].key",snapshots[self.index].key)
                refs.child(snapshots[self.index].key)  //choose the cell equal index
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        
                        
                        refs.child(snapshots[self.index].key).child("JoinBy")
                            .queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in
                                
                                
                                refs.child(snapshots[self.index].key).child("JoinBy").child(self.uid ?? "").setValue(self.uid)
                                print("Join sucessfully !")
                                let refOrder = Database.database().reference().child("GroupBuyOrder").childByAutoId()
                                let orderId = refOrder.key
                                
                                
                                Database.database().reference(withPath: "UserGroupBuy/\(self.uid ?? "wrong message : NoCurrentUser")/OrderId/\(orderId ?? "" )/ProductId/").setValue(self.productId)
                                
                                
                                vc.orderAutoId = orderId ?? ""
                                vc.openId = snapshots[self.index].key
                                refOrder.child("OpenGroupId").setValue(snapshots[self.index].key)
                                refOrder.child("Payment").setValue(self.payFee)
                                refOrder.child("OrderCreateTime").setValue(self.getTime())
                                refOrder.child("Comment").setValue("false")
                                
                                
                                
                                
                                
                            })   
                        
                        
                        
                        self.ref.child(self.productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            let value = snapshot.value as? NSDictionary
                            let price = value?["Price"] as? String ?? ""
                            let payment = Int(price)
                            let allPay = (payment ?? 0) as Int + 60
                            vc.payFee = String(allPay) 
                            vc.productId = self.productId
                            vc.productIndex = self.productIndex
                            vc.groupBuyStyle = self.groupBuyStyle
                            vc.groupBuyPeople = self.groupBuyPeople
                            let message = UIAlertController(title: "結帳成功", message: nil, preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
                            {action in
                                print("checkout success")
                                self.navigationController?.pushViewController(vc, animated: true)
                            })
                            message.addAction(confirmAction)
                            self.present(message, animated: true, completion: nil)
                            //                            self.navigationController?.pushViewController(vc,animated: true)
                            
                        })
                    })
            }
            
        })
    }
    
    func getTime() -> String {
        //    時間戳看開始    
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = String(timeInterval)
        print("timeStamp：\(timeStamp)")
        
        let date = Date(timeIntervalSince1970: timeInterval)
        //格式化
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print("新增日期時間：\(dformatter.string(from: date))")
        //    時間戳結束
        
        return timeStamp
    }
    
    
    
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}
extension GroupBuyOrderConfirmController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderComfirmCollectionViewCell", for: indexPath) as! OrderComfirmCollectionViewCell
        print("self.productId",self.productId)
        cell.setProductLabel(productId: String(self.productId), fromShoppingCart: false)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        let groupBuyRef =  Database.database().reference().child("GroupBuy")
        groupBuyRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            print("key:" ,self.productId)
            groupBuyRef.child(self.productId).child("ProductEvaluation").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.children.allObjects as! [DataSnapshot]
                vc.commentCount = data.count
                vc.index = self.productIndex
                vc.productId = self.productId
                vc.from = "GroupBuy"
                self.navigationController?.pushViewController(vc,animated: true)
            })
            
            
        })
        
        
        
        
    }
}

extension GroupBuyOrderConfirmController: UICollectionViewDelegateFlowLayout{
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
