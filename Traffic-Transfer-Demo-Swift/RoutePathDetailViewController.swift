//
//  RoutePathDetailViewController.swift
//  Drive-Route-Demo
//
//  Created by eidan on 16/12/22.
//  Copyright © 2016年 autonavi. All rights reserved.
//

import UIKit

class RoutePathDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let RoutePathDetailStepInfoImageName = "RoutePathDetailStepInfoImageName"
    let RoutePathDetailStepInfoText = "RoutePathDetailStepInfoText"
    
    //xib views
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var timeInfoLabel: UILabel!
    
    @IBOutlet weak var taxiCostInfoLabel: UILabel!
    
    let RoutePathDetailTableViewCellIdentifier = "RoutePathDetailTableViewCellIdentifier"
    
    var route: AMapRoute!;
    
    var transit: AMapTransit!;
    
    var routeDetailDataArray: NSMutableArray = []  //路径步骤数组
    
    //根据transit的具体字段，显示信息
    func setUpViewsWithData() {
        
        let hours = self.transit!.duration / 3600
        let minutes = Int(self.transit!.duration / 60) % 60
        self.timeInfoLabel.text = "\(UInt(hours))小时\(UInt(minutes))分钟（\(UInt(self.transit!.distance) / 1000)公里）"
        self.taxiCostInfoLabel.text = String(format: "打车约%.0f元", self.route.taxiCost)
        
        self.routeDetailDataArray = []
        
        self.routeDetailDataArray.add([RoutePathDetailStepInfoImageName : "start", RoutePathDetailStepInfoText : "开始出发"])
        
        for segment: AMapSegment in self.transit.segments as Array {
            
            if segment.walking != nil {
                let walkInfo = "步行\(segment.walking.distance)米"
                self.routeDetailDataArray.add([RoutePathDetailStepInfoImageName : "walkRoute", RoutePathDetailStepInfoText : walkInfo])
            }
            
            if (segment.buslines.first?.name != nil) {
                
                let busline: AMapBusLine = segment.buslines.first!
                
                var busImageName = "busRoute"
                if busline.type == "地铁线路" { //区分公交和地铁
                    busImageName = "underGround"
                }
                
                //viaBusStops途径的公交车站的数组，如需具体站名，可解析。
                let busInfoText = String(format: "乘坐%@，在 %@ 上车，途经 %u 站，在 %@ 下车", busline.name,busline.departureStop.name,busline.viaBusStops.count + 1,busline.arrivalStop.name)
                
                self.routeDetailDataArray.add([RoutePathDetailStepInfoImageName : busImageName, RoutePathDetailStepInfoText : busInfoText])
                
            } else if segment.railway.uid != nil {
                self.routeDetailDataArray.add([RoutePathDetailStepInfoImageName : "railwayRoute", RoutePathDetailStepInfoText : segment.railway.name])
            }
            
        }
        
        self.routeDetailDataArray.add([RoutePathDetailStepInfoImageName : "end", RoutePathDetailStepInfoText : "抵达终点"])
    }
    
    // MARK: - UITableView Delegate and DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routeDetailDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RoutePathDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: RoutePathDetailTableViewCellIdentifier, for: indexPath) as! RoutePathDetailTableViewCell)
        
        let stepInfo: [String : String] = self.routeDetailDataArray.object(at: indexPath.row) as! Dictionary
        
        cell.infoLabel.text = stepInfo[RoutePathDetailStepInfoText]
        cell.actionImageView.image = UIImage(named: stepInfo[RoutePathDetailStepInfoImageName]!)
        
        
        cell.topVerticalLine.isHidden = indexPath.row == 0
        cell.bottomVerticalLine.isHidden = indexPath.row == self.routeDetailDataArray.count - 1

        return cell
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.headerView  //这边不能写成self.tableView.tableHeaderView? ＝ self.headerView 或者self.tableView.tableHeaderView! = self.headerView 否则出不来
        self.tableView.register(UINib(nibName: "RoutePathDetailTableViewCell", bundle: nil), forCellReuseIdentifier: RoutePathDetailTableViewCellIdentifier)
        self.tableView.rowHeight = 54
        
        self.setUpViewsWithData()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - xib click
    
    @IBAction func goBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
