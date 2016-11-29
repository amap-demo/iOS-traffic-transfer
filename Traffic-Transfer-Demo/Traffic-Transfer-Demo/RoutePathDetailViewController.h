//
//  RoutePathDetailViewController.h
//  Traffic-Transfer-Demo
//
//  Created by eidan on 16/11/29.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMapRoute;
@class AMapTransit;

@interface RoutePathDetailViewController : UIViewController

@property (strong, nonatomic) AMapRoute *route;
@property (strong, nonatomic) AMapTransit *transit;

@end
