//
//  RankingViewController.swift
//  zhuishushenqi
//
//  Created by Nory Chao on 16/9/19.
//  Copyright © 2016年 QS. All rights reserved.
//

import UIKit
import QSNetwork
import QSKingfisher

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class RankingViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    fileprivate var tableView:UITableView?
    
    fileprivate var maleRank:[QSRankModel]? = [QSRankModel]()
    fileprivate var femaleRank:[QSRankModel]? = [QSRankModel]()
    fileprivate var showMale:Bool = false
    fileprivate var showFemale:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        title = "排行榜"
        initSubview()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    fileprivate func initSubview(){
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight - 64), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorInset = UIEdgeInsetsMake(0, 44, 0, 0)
        
        tableView.qs_registerCellClass(RankingViewCell.self)
        self.tableView = tableView
        self.tableView?.checkEmpty()
    }
    
    fileprivate func requestData(){
        QSNetwork.request("\(BASEURL)/\(RANKING)") { (response) in
            if let dict = response.json as? NSDictionary {
                do{
                    if let male:[Any] = dict["male"] as? [Any] {
                       self.maleRank = try XYCBaseModel.model(withModleClass: QSRankModel.self, withJsArray: male) as? [QSRankModel]
                        //添加别人家的榜单
                        let otherRank = self.rankModel(title: "别人家的榜单", image: "ranking_other")
                        self.maleRank?.insert(otherRank, at: 5)
                    }
                    if let female:[Any] = dict["female"] as? [Any] {
                        
                        self.femaleRank = try XYCBaseModel.model(withModleClass: QSRankModel.self, withJsArray: female ) as? [QSRankModel]
                        let otherRank = self.rankModel(title: "别人家的榜单", image: "ranking_other")
                        self.femaleRank?.insert(otherRank, at: 5)
                    }
                    
                    DispatchQueue.main.async {
                        self.view.addSubview(self.tableView!)
                        self.tableView?.reloadData()
                    }
                }catch{
                    
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (showMale ? maleRank!.count : 6)
        }else if section == 1{
            return (showFemale ? femaleRank!.count : 6)
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RankingViewCell? = tableView.qs_dequeueReusableCell(RankingViewCell.self)
        cell?.imageView?.contentMode = .scaleAspectFill
        cell?.backgroundColor = UIColor.white
        cell?.selectionStyle = .none
        
        var rank:[QSRankModel]? = [QSRankModel]()
        indexPath.section == 0 ? (rank = maleRank) : (rank = femaleRank)
        cell?.model = rank?[indexPath.row]
        cell?.accessoryClosure = {
            if indexPath.section == 0 {
                self.showMale = !self.showMale
                self.tableView?.reloadData()
            }else{
                self.showFemale = !self.showFemale
                self.tableView?.reloadData()
            }
        }
        tableView.checkEmpty()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: ScreenWidth,height: 60))
        let label = UILabel(frame: CGRect(x: 15,y: 15,width: 100,height: 15))
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 11)
        if section == 0 {
            label.text = "男生"
        }else if section == 1{
            label.text = "女生"
        }
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var rank:[[QSRankModel]] = [maleRank!,femaleRank!]
        if indexPath.row == 5{
            if indexPath.section == 0 {
                showMale = !showMale
            }else{
                showFemale = !showFemale
            }
            let cell:RankingViewCell? = self.tableView?.cellForRow(at: indexPath) as? RankingViewCell
            cell?.accessoryImageView.isSelected = showMale
            self.tableView?.reloadData()
            return
        }
        let topVC = TopDetailViewController()
        topVC.id = rank[indexPath.section][indexPath.row]._id
        topVC.title = rank[indexPath.section][indexPath.row].title
        topVC.model = rank[indexPath.section][indexPath.row]
        self.navigationController?.pushViewController(topVC, animated: true)

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    func rankModel(title:String,image:String)->QSRankModel{
        let otherRank = QSRankModel()
        otherRank.title = title
        otherRank.image = image
        return otherRank
    }
}

public class QSResource:Resource{
    
    public var imageURL:URL? = URL(string: "http://statics.zhuishushenqi.com/ranking-cover/142319144267827")
    public var downloadURL: URL {
        return imageURL!
    }
    
    public var cacheKey: String{
        return "\(self.imageURL)"
    }
    
    init(url:URL) {
        self.imageURL = url
    }
}
