//
//  HistoryOrderInformationController.swift
//  vip
//
//  Created by Ines on 2020/4/23.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class HistoryOrderInformationController: UIViewController {
    
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var orderCreateTime: UILabel!
    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var deliverStartTime: UILabel!
    @IBOutlet weak var deliverArriveTime: UILabel!
    @IBOutlet weak var orderFinishTime: UILabel!
    
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var payWay: UILabel!
    @IBOutlet weak var deliverWay: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //history order cpntroller 傳值過來
    var orderIndex = Int()
    var orderIds = String()
    var productIdString = [String]()
    var progresss = String()
    var payments = String()
    var orderCreateTimes = String()
    var orderEndTime = String()
    
    
    //layout
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
        setLabel()
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
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProcessingOrderInformationCell", bundle: nil), forCellWithReuseIdentifier: "ProcessingOrderInformationCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func setLabel(){
        
        orderId.text = orderIds
        payment.text = "付款總金額    " + payments + "元"
        progress.text = "此訂單已取貨"
        
        
        
        //time
        let createTimeStamp = Double(orderCreateTimes) ?? 1000000000
        let endTimeStamp = Double(orderEndTime) ?? 1000000000
        
        let createTimeInterval:TimeInterval = TimeInterval(createTimeStamp)
        let endTimeInterval:TimeInterval = TimeInterval(endTimeStamp)
        
        let createDate = Date(timeIntervalSince1970: createTimeInterval)
        let endDate = Date(timeIntervalSince1970: endTimeInterval)
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        print("新增日期時間：\(dformatter.string(from: createDate))")
        orderCreateTime.text = dformatter.string(from: createDate)
        orderFinishTime.text = dformatter.string(from: endDate)
        
        //payway deliverway
        let userProfileRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
            .child("Profile")
        userProfileRef.queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String:Any]
                    else {
                        print("Error")
                        return
                }
                let deliverWays = value["deliverWays"] as? String
                let paymentWays = value["paymentWays"] as? String
                self.payWay.text = "付款方式    " + (paymentWays!)
                self.deliverWay.text = "寄送方式    " + (deliverWays!)
            })
    }
    
    @IBAction func detailInformationButtonWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DeadLine", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DeadLineController") as!  DeadLineController
        vc.productIdString = productIdString
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func commentButtonWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentAllController") as!  CommentAllController
        vc.orderIds = orderIds //要給 Comment Controller用
        vc.orderIndex = orderIndex
        vc.productIdString = productIdString
        vc.productIdStringAll = productIdString
        vc.progresss = progresss
        vc.payment = payments
        vc.orderCreateTimes = orderCreateTimes
        vc.orderEndTime = orderEndTime
        checkIfCommentBefore(vc:vc)
    }
    
    func checkIfCommentBefore(vc:CommentAllController){
        let orderRef = Database.database().reference().child("ProductOrder").child(orderIds)
        orderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let comment = value?["Comment"] as? String
            print("comment",comment ?? "")      
            if comment == "false"{
                vc.productIdString = self.productIdString
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                orderRef.child("CommentProductId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    let value = snapshot.value as? NSDictionary
                    var needComment = [String]()
                    for i in self.productIdString {
                        let commentProductId = value?[i] as? String
                        if commentProductId == nil { //沒評論過
                            print("沒評論過",i )
                            needComment.append(i)
                        }
                    }
                    print("needComment 沒評論過的有",needComment)
                    vc.productIdString = needComment
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                })
            }
        })
        
    }
    
    
}
extension HistoryOrderInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return productIdString.count
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProcessingOrderInformationCell", for: indexPath) as! ProcessingOrderInformationCell
        cell.setLabel(productId:productIdString[indexPath.row])
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        let productRef =  Database.database().reference().child("Product")
        productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            productRef.child(self.productIdString[indexPath.row]).child("ProductEvaluation").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.children.allObjects as! [DataSnapshot]
                vc.commentCount = data.count
                print("commentCount",data.count)
                vc.fromMyOrder = true
                vc.productId = self.productIdString[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            })
        })
        
    }
}

extension HistoryOrderInformationController: UICollectionViewDelegateFlowLayout{
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



