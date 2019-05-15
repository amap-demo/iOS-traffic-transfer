//
//  RootViewController.swift
//  WalkRoutePlanDemo
//
//  Created by eidan on 17/1/5.
//  Copyright © 2017年 Amap. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let TrafficTransferCollectionViewCellIdentifier = "TrafficTransferCollectionViewCellIdentifier"
    
    let RoutePlanningPaddingEdge = CGFloat(20)
    let RoutePlanningViewControllerStartTitle = "起点"
    let RoutePlanningViewControllerDestinationTitle = "终点"
    
    var mapView: MAMapView!         //地图
    var search: AMapSearchAPI!      // 地图内的搜索API类
    var route: AMapRoute!           //路径规划信息
    var naviRoute: MANaviRoute?     //用于显示当前路线方案.
    
    var startAnnotation: MAPointAnnotation!
    var destinationAnnotation: MAPointAnnotation!
    
    var startCoordinate: CLLocationCoordinate2D! //起始点经纬度
    var destinationCoordinate: CLLocationCoordinate2D! //终点经纬度
    
    var currentRouteIndex: NSInteger!   //当前显示线路的索引值，从0开始
    var routeArray: NSArray!  //规划的路径数组，collectionView的数据源
    
    //xibViews
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpXibViews()
        
        self.initMapViewAndSearch()
        
        self.setUpData()
        
        self.resetSearchResultAndXibViewsToDefault()
        
        self.addDefaultAnnotations()
        
        self.searchRoutePlanningBus()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //初始化xib中的视图
    func setUpXibViews() {
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.register(UINib.init(nibName: "TrafficTransferCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TrafficTransferCollectionViewCellIdentifier)
        self.collectionViewLayout.itemSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 80)
    }
    
    //初始化地图,和搜索API
    func initMapViewAndSearch() {
        self.mapView = MAMapView(frame: CGRect(x: CGFloat(0), y: CGFloat(64), width: CGFloat(self.view.bounds.size.width), height: CGFloat(self.view.bounds.size.height - 80 - 64)))
        self.mapView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        self.view.sendSubview(toBack: self.mapView)
        self.search = AMapSearchAPI()
        self.search.delegate = self
    }
    
    //初始化坐标数据
    func setUpData() {
        self.startCoordinate = CLLocationCoordinate2DMake(39.910267, 116.370888)
        self.destinationCoordinate = CLLocationCoordinate2DMake(39.989872, 116.481956)
    }
    
    //初始化或者规划失败后，设置view和数据为默认值
    func resetSearchResultAndXibViewsToDefault() {
        self.currentRouteIndex = 0
        self.routeArray = []  //这边初始化，空数组，不能为nil
        self.pageControl.isHidden = true
        self.collectionView.reloadData()
        self.naviRoute?.removeFromMapView()
        
    }
    
    //在地图上添加起始和终点的标注点
    func addDefaultAnnotations() {
        let startAnnotation = MAPointAnnotation()
        startAnnotation.coordinate = self.startCoordinate
        startAnnotation.title = RoutePlanningViewControllerStartTitle
        startAnnotation.subtitle = "{\(self.startCoordinate.latitude), \(self.startCoordinate.longitude)}"
        self.startAnnotation = startAnnotation
        let destinationAnnotation = MAPointAnnotation()
        destinationAnnotation.coordinate = self.destinationCoordinate
        destinationAnnotation.title = RoutePlanningViewControllerDestinationTitle
        destinationAnnotation.subtitle = "{\(self.destinationCoordinate.latitude), \(self.destinationCoordinate.longitude)}"
        self.destinationAnnotation = destinationAnnotation
        self.mapView.addAnnotation(startAnnotation)
        self.mapView.addAnnotation(destinationAnnotation)
    }
    
    //步行路线开始规划
    func searchRoutePlanningBus() {
        let navi = AMapTransitRouteSearchRequest()
        navi.requireExtension = true
        navi.city = "beijing"  //指定城市，必填
        
        /* 出发点. */
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(self.startCoordinate.latitude), longitude: CGFloat(self.startCoordinate.longitude))
        
        /* 目的地. */
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(self.destinationCoordinate.latitude), longitude: CGFloat(self.destinationCoordinate.longitude))
        
        self.search.aMapTransitRouteSearch(navi)
    }
    
    //在地图上显示当前选择的路径
    func presentCurrentRouteCourse() {
        
        if self.routeArray.count <= 0 {
            return
        }
        self.naviRoute?.removeFromMapView() //清空地图上已有的路线
        
        let startPoint = AMapGeoPoint.location(withLatitude: CGFloat(self.startAnnotation.coordinate.latitude), longitude: CGFloat(self.startAnnotation.coordinate.longitude)) //起点
        
        let endPoint = AMapGeoPoint.location(withLatitude: CGFloat(self.destinationAnnotation.coordinate.latitude), longitude: CGFloat(self.destinationAnnotation.coordinate.longitude))  //终点
        
        //根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
        self.naviRoute = MANaviRoute(for: self.route.transits[self.currentRouteIndex], start: startPoint, end: endPoint)
        self.naviRoute?.add(to: self.mapView)
        
        //显示到地图上
        let edgePaddingRect = UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
        //缩放地图使其适应polylines的展示
        self.mapView.setVisibleMapRect(CommonUtility.mapRect(forOverlays: self.naviRoute?.routePolylines), edgePadding: edgePaddingRect, animated: true)
    }
    
    
    // MARK: - AMapSearchDelegate
    
    //当路径规划搜索请求发生错误时，会调用代理的此方法
    func aMapSearchRequest(_ request: Any, didFailWithError error: Error?) {
        print("Error: \(String(describing: error))")
        self.resetSearchResultAndXibViewsToDefault()
    }
    
    //路径规划搜索完成回调.
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest, response: AMapRouteSearchResponse) {
        if response.route == nil {
            self.resetSearchResultAndXibViewsToDefault()
            return
        }
        self.route = response.route
        self.currentRouteIndex = 0
        self.routeArray = self.route.transits as NSArray!  //给公交换乘方案作为collectionView的数据源
        
        self.collectionView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
        self.collectionView.reloadData()
        self.pageControl.isHidden = false
        self.pageControl.numberOfPages = self.routeArray.count
        self.pageControl.currentPage = self.currentRouteIndex
        
        self.presentCurrentRouteCourse()
    }
    
    // MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        //虚线，如需要步行的
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 6
            renderer.strokeColor = UIColor.red
            renderer.lineDash = true
            
            return renderer
        }
        
        //showTraffic为NO时，不需要带实时路况，路径为单一颜色，比如步行线路目前为海蓝色
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 6
            
            if naviPolyline.type == MANaviAnnotationType.walking {
                renderer.strokeColor = naviRoute?.walkingColor
            }
            else if naviPolyline.type == MANaviAnnotationType.railway {
                renderer.strokeColor = naviRoute?.railwayColor;
            }
            else {
                renderer.strokeColor = naviRoute?.routeColor;
            }
            
            return renderer
        }
        
        //showTraffic为YES时，需要带实时路况，路径为多颜色渐变
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline!)
            renderer.lineWidth = 6
            renderer.strokeColors = naviRoute?.multiPolylineColors
            
            return renderer
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            
            //标注的view的初始化和复用
            let pointReuseIndetifier = "RoutePlanningCellIdentifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            annotationView!.image = nil
            
            if annotation.isKind(of: MANaviAnnotation.self) {
                let naviAnno = annotation as! MANaviAnnotation
                
                switch naviAnno.type {
                case MANaviAnnotationType.railway:
                    annotationView!.image = UIImage(named: "railway_station")
                    break
                case MANaviAnnotationType.drive:
                    annotationView!.image = UIImage(named: "car")
                    break
                case MANaviAnnotationType.riding:
                    annotationView!.image = UIImage(named: "ride")
                    break
                case MANaviAnnotationType.walking:
                    annotationView!.image = UIImage(named: "man")
                    break
                case MANaviAnnotationType.bus:
                    annotationView!.image = UIImage(named: "bus")
                    break
                }
            }
            else {
                if annotation.title == "起点" {
                    annotationView!.image = UIImage(named: "startPoint")
                }
                else if annotation.title == "终点" {
                    annotationView!.image = UIImage(named: "endPoint")
                }
            }
            return annotationView!
        }
        
        return nil
    }
    
    // MARK: - UICollectionViewDelegate and DataSource
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let index:NSInteger = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
            if self.currentRouteIndex != index {
                self.currentRouteIndex = index
                self.pageControl.currentPage = self.currentRouteIndex
                self .presentCurrentRouteCourse()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.routeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TrafficTransferCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrafficTransferCollectionViewCellIdentifier, for: indexPath) as! TrafficTransferCollectionViewCell
        
        let transit: AMapTransit = self.routeArray.object(at: indexPath.row) as! AMapTransit
        
        cell.configureWithTransit(transit: transit)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let routePathDetailViewController = RoutePathDetailViewController(nibName: "RoutePathDetailViewController", bundle: nil)
        routePathDetailViewController.route = self.route
        routePathDetailViewController.transit = self.route.transits[self.currentRouteIndex]
        self.navigationController!.pushViewController(routePathDetailViewController, animated: true)
    }
    
    
    // MARK: - Xib Btn Click
    
    //重新规划按钮点击
    @IBAction func restartSearch(_ sender: Any) {
        self.searchRoutePlanningBus()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
