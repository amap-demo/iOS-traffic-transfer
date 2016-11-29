//
//  TrafficTransferCollectionViewCell.h
//  Traffic-Transfer-Demo
//
//  Created by eidan on 16/11/29.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMapTransit;

#define TrafficTransferCollectionViewCellIdentifier     @"TrafficTransferCollectionViewCellIdentifier"

@interface TrafficTransferCollectionViewCell : UICollectionViewCell

- (void)configureWithTransit:(AMapTransit *)transit;

@end
