
//
//  TableViewCell.swift
//  vip
//
//  Created by rourou on 03/03/2020.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ShoppingCartCell: UITableViewCell{
    
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var Price: UILabel!
    var ref: DatabaseReference!
//    var count = Int()
    
//    func getCount() -> Int{
//        ref = Database.database().reference()
//        let user = Auth.auth().currentUser!
//
//
//        self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
//            self.count = snapshot.children.allObjects.count
//        })
//        return self.count
//    }
    
    func loadData(index:Int){
           ref = Database.database().reference()
           let user = Auth.auth().currentUser!
           
        
        self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            
//            self.count = snapshot.children.allObjects.count
//
//            let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "ShoppingCart") as!  ShoppingCartController
//            vc.count = self.count
//            print("self.count = ", self.count)
            
            
            if let data = snapshot.children.allObjects as? [DataSnapshot] {
                print(data)
                let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                print("retriName:",retriName)
                let retriprice = data.compactMap({($0.value as![String:Any])["Price"]})
                let imageURL = data.compactMap({
                    ($0.value as! [String: Any])["imageURL"]
                })
                self.ProductName.text = retriName[index] as? String
                self.Price.text = retriprice[index] as? String
                
                let productImageUrl = imageURL[index]
                self.ProductImage.image = UIImage(named: "logo")
                if let imageUrl = URL(string: productImageUrl as! String){
                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let imageData = data {
                            DispatchQueue.main.async {
                                self.ProductImage.image = UIImage(data: imageData)
                            }
                        }
                        
                    }.resume()
                    
                }
                
            }
            
        })
        
    }
    
    @IBAction func InfoButton(_ sender: UIButton) {
    }
    
    
    @IBAction func LikeButton(_ sender: UIButton) {
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton){
        if sender.isSelected{
            print("Selected!")
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
    @IBAction func ListBtnTapped(_ sender: UIButton) {
        if sender.isSelected{
            print("Like Button Selected!")
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
    
}
