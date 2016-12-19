//
//  RoutePathDetailViewController.m
//  Traffic-Transfer-Demo
//
//  Created by eidan on 16/11/29.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import "RoutePathDetailViewController.h"
#import "RoutePathDetailTableViewCell.h"
#import <AMapSearchKit/AMapSearchKit.h>


static const NSString *RoutePathDetailStepInfoImageName = @"RoutePathDetailStepInfoImageName";
static const NSString *RoutePathDetailStepInfoText = @"RoutePathDetailStepInfoText";

@interface RoutePathDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

//data
@property (strong, nonatomic) NSMutableArray *routeDetailDataArray;  //路径步骤数组

//xib views
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *timeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxiCostInfoLabel;


@end

@implementation RoutePathDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"RoutePathDetailTableViewCell" bundle:nil] forCellReuseIdentifier:RoutePathDetailTableViewCellIdentifier];
    self.tableView.rowHeight = 54;
    
    [self setUpViewsWithData];
    
    // Do any additional setup after loading the view from its nib.
}

//根据transit的具体字段，显示信息
- (void)setUpViewsWithData {
    
    NSInteger hours = self.transit.duration / 3600;
    NSInteger minutes = (NSInteger)(self.transit.duration / 60) % 60;
    self.timeInfoLabel.text = [NSString stringWithFormat:@"%u小时%u分钟（%u公里）",(unsigned)hours,(unsigned)minutes,(unsigned)self.transit.distance / 1000];
    self.taxiCostInfoLabel.text = [NSString stringWithFormat:@"打车约%.0f元",self.route.taxiCost];
    
    self.routeDetailDataArray = @[].mutableCopy;
    [self.routeDetailDataArray addObject:@{RoutePathDetailStepInfoImageName : @"start",RoutePathDetailStepInfoText : @"开始出发"}]; // 图片的名字，具体步骤的文字信息

    for (AMapSegment *segment in self.transit.segments) {
        AMapRailway *railway = segment.railway; //火车
        AMapBusLine *busline = [segment.buslines firstObject];  // 地铁或者公交线路
        AMapWalking *walking = segment.walking;  //搭乘地铁或者公交前的步行信息
        
        if (walking.distance) {
            NSString *walkInfo = [NSString stringWithFormat:@"步行%u米",(unsigned)walking.distance];
            [self.routeDetailDataArray addObject:@{RoutePathDetailStepInfoImageName : @"walkRoute",RoutePathDetailStepInfoText : walkInfo}];
        }
        
        if (busline.name) {
            NSString *busImageName = @"busRoute";
            if ([busline.type isEqualToString:@"地铁线路"]) { //区分公交和地铁
                busImageName = @"underGround";
            }
            
            //viaBusStops途径的公交车站的数组，如需具体站名，可解析。
            NSString *busInfoText = [NSString stringWithFormat:@"乘坐%@，在 %@ 上车，途经 %u 站，在 %@ 下车",busline.name,busline.departureStop.name,(unsigned)(busline.viaBusStops.count + 1),busline.arrivalStop.name];
            [self.routeDetailDataArray addObject:@{RoutePathDetailStepInfoImageName : busImageName,RoutePathDetailStepInfoText : busInfoText}];
            
        } else if (railway.uid) {
            [self.routeDetailDataArray addObject:@{RoutePathDetailStepInfoImageName : @"railwayRoute",RoutePathDetailStepInfoText : railway.name}];
        }
    }
    
    [self.routeDetailDataArray addObject:@{RoutePathDetailStepInfoImageName : @"end",RoutePathDetailStepInfoText : @"抵达终点"}];

}

#pragma -mark UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeDetailDataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoutePathDetailTableViewCell *cell = (RoutePathDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RoutePathDetailTableViewCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *stepInfo = [self.routeDetailDataArray objectAtIndex:indexPath.row];
    
    cell.infoLabel.text = stepInfo[RoutePathDetailStepInfoText];
    cell.actionImageView.image = [UIImage imageNamed:stepInfo[RoutePathDetailStepInfoImageName]];
    
    cell.topVerticalLine.hidden = indexPath.row == 0;
    cell.bottomVerticalLine.hidden = indexPath.row == self.routeDetailDataArray.count - 1;
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Xib Btn Click

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
