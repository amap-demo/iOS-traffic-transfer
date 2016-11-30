//
//  TrafficTransferCollectionViewCell.m
//  Traffic-Transfer-Demo
//
//  Created by eidan on 16/11/29.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import "TrafficTransferCollectionViewCell.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface TrafficTransferCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *trafficTransferInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherInfoLabel;


@end

@implementation TrafficTransferCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureWithTransit:(AMapTransit *)transit {
    
    NSMutableArray *buslineArray = @[].mutableCopy;
    for (AMapSegment *segment in transit.segments) {
        AMapRailway *railway = segment.railway; //火车,一个城市内的不会出现火车。
        AMapBusLine *busline = [segment.buslines firstObject];  // 地铁或者公交线路
        if (busline.name) {
            [buslineArray addObject:busline.name];
        } else if (railway.uid) {
            [buslineArray addObject:railway.name];
        }
    }
    self.trafficTransferInfoLabel.text = [buslineArray componentsJoinedByString:@" > "];
    
    NSInteger hours = transit.duration / 3600;
    NSInteger minutes = (NSInteger)(transit.duration / 60) % 60;
    self.otherInfoLabel.text = [NSString stringWithFormat:@"%u小时%u分钟 | %u公里 | 步行%.1f公里",(unsigned)hours,(unsigned)minutes,(unsigned)transit.distance / 1000,transit.walkingDistance / 1000.0];
}


@end
