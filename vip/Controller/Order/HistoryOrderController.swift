//
//  ProcessingOrderController.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class HistoryOrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var zeroOrder: UILabel!
    
    
    //layout
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    var myOrderCount = Int()
    var myOrderId = [String]()
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
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
        collectionView.register(UINib(nibName: "HistoryOrderCell", bundle: nil), forCellWithReuseIdentifier: "HistoryOrderCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func getOrderProductId(orderIndex:Int,orderId:String,vc:HistoryOrderInformationController){
        let productOrderRef = Database.database().reference().child("ProductOrder").child(orderId)
        var productIdStrings = [String]()
        
        productOrderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let orderProgress = value?["OrderStatus"] as? String ?? ""
            let payment = value?["Payment"] as? String ?? ""
            let orderCreateTime = value?["OrderCreateTime"] as? String ?? ""
            let orderEndTime = value?["OrderEndTime"] as? String ?? ""
            
            //find what productIds in this order
            let productIdString = value?["ProductId"] as? [String]
            print("productIdString",productIdString ?? "")            
            let productCount = (productIdString?.count) ?? 0 as Int 
            
            for i in 0 ... productCount-1 {
                productIdStrings.append(productIdString?[i] ?? "")
            }            
            
            vc.orderIndex = orderIndex
            vc.orderIds = self.myOrderId[orderIndex]
            vc.productIdString = productIdStrings
            vc.progresss = orderProgress
            vc.payments = payment
            vc.orderCreateTimes = orderCreateTime
            vc.orderEndTime = orderEndTime
            
            self.navigationController?.pushViewController(vc,animated: true)
            
        })
        
    }
    @IBAction func backToMain(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}



extension HistoryOrderController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        if myOrderCount != 0 {
            zeroOrder.isHidden = true
        }
        return myOrderCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryOrderCell", for: indexPath) as! HistoryOrderCell
        cell.setLabel(orderId:myOrderId[indexPath.row])
        
        return cell    
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HistoryOrderInformationControllerId") as!  HistoryOrderInformationController
        getOrderProductId(orderIndex: indexPath.row, orderId: myOrderId[indexPath.row], vc:vc )
        
        
        
    }
}

extension HistoryOrderController: UICollectionViewDelegateFlowLayout{
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



