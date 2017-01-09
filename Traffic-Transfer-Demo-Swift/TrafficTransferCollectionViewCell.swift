//
//  TrafficTransferCollectionViewCell.swift
//  Traffic-Transfer-Demo
//
//  Created by eidan on 17/1/6.
//  Copyright © 2017年 autonavi. All rights reserved.
//

import UIKit

class TrafficTransferCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var trafficTransferInfoLabel: UILabel!

    @IBOutlet weak var otherInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithTransit(transit: AMapTransit ) {
        
        var buslineArray = [String]();
        
        for segment: AMapSegment in transit.segments {
            let railway = segment.railway
            let busline = segment.buslines.first
            if busline?.name != nil {
                buslineArray.append((busline?.name)!)
            } else if ((railway?.uid) != nil) {
                buslineArray.append((railway?.name)!)
            }
        }
        
        self.trafficTransferInfoLabel.text = buslineArray.joined(separator: " > ")
        
        let hours = transit.duration / 3600
        let minutes = (transit.duration / 60) % 60
        let distance = String(format: "%.0f", CGFloat(transit.distance) / CGFloat(1000))
        let walkDistance = String(format: "%0.1f", CGFloat(transit.walkingDistance) / CGFloat(1000))
        let cost = String(format: "%.0f", transit.cost)
        self.otherInfoLabel.text = "\(hours)小时\(minutes)分钟 | \(distance)公里 | \(cost)元 | 步行\(walkDistance)公里"
    }
    
    

}
