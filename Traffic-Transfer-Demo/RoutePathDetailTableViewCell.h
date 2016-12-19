//
//  RoutePathDetailTableViewCell.h
//  Traffic-Transfer-Demo
//
//  Created by eidan on 16/11/29.
//  Copyright © 2016年 autonavi. All rights reserved.
//


#import <UIKit/UIKit.h>

#define RoutePathDetailTableViewCellIdentifier      @"RoutePathDetailTableViewCellIdentifier"

@interface RoutePathDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *topVerticalLine;
@property (weak, nonatomic) IBOutlet UIView *bottomVerticalLine;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;


@end
