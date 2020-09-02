//
//  QCTrackOverlyViewController.m
//  erp
//
//  Created by apple on 2020/8/20.
//  Copyright © 2020 sdqc56. All rights reserved.
//

#import "QCTrackOverlyViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "QCLocationModel.h"
#import "CustomAnnotationView.h"
#import "NSObject+YYModel.h"
#import "CommonUtility.h"
#import "MANaviRoute.h"
#import <Masonry.h>
#define WAYPonts 16
#define kCalloutViewMargin -8

static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
static const NSInteger RoutePlanningPaddingEdge                    = 20;
@interface QCTrackOverlyViewController () <MAMapViewDelegate, AMapSearchDelegate>
/* 路径规划类型 */
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, assign) int index;


@end

@implementation QCTrackOverlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation = NO;
    
}
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[MAMapView alloc] init];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 14;
    // 开启定位
//    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
   
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(64);
        make.bottom.equalTo(self.view).mas_offset(-64);
    }];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"track.json" ofType:nil];
       NSData *data = [NSData dataWithContentsOfFile:path];
       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
       NSArray *modelArray = [NSArray yy_modelArrayWithClass:QCLocationModel.class json:dict[@"data"]];
       [self dealWithTrackData:modelArray];
}

- (void)dealWithTrackData:(NSArray *)dataArray{
    if(dataArray) {
        [self addAction:dataArray];
        
        NSInteger consult = (dataArray.count - 1) / (WAYPonts -1);
        BOOL remainder = (dataArray.count - 1) % (WAYPonts -1) > 0;
        if (remainder) { consult += 1; }
        
        [self addPlanRoult:consult trackData:dataArray];
    }
}

-(void)addPlanRoult:(NSInteger)number trackData:(NSArray *)dataArray
{
    for ( int i = 0; i < number; i++ )
    {
        NSInteger startIndex = (WAYPonts - 1) * i;
        NSInteger destinationIndex = (WAYPonts - 1) * (i + 1);
        destinationIndex = MIN(destinationIndex, dataArray.count - 1);
        
        
        QCLocationModel *startModel = dataArray[startIndex];
        QCLocationModel *destinationModel = dataArray[destinationIndex];
        _startCoordinate        = AMapCoordinateConvert(CLLocationCoordinate2DMake([startModel.lat floatValue], [startModel.lng floatValue]), AMapCoordinateTypeGPS);
        _destinationCoordinate  = AMapCoordinateConvert(CLLocationCoordinate2DMake([destinationModel.lat floatValue], [destinationModel.lng floatValue]), AMapCoordinateTypeGPS);
        [self addDefaultAnnotations];
        [self searchRoutePlanningDrive:dataArray startIndex:startIndex destinationIndex:destinationIndex];
    }
}

#pragma mark - do search
- (void)searchRoutePlanningDrive:(NSArray *)dataArray startIndex:(long int)startIndex destinationIndex:(long int)destinationIndex
{
    self.startAnnotation.coordinate = _startCoordinate;
    self.destinationAnnotation.coordinate = _destinationCoordinate;
    
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    navi.strategy = 0;
    navi.requireExtension = NO;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    NSMutableArray *wayArray = [NSMutableArray arrayWithCapacity:0];

    for (long int j = startIndex+1; j< destinationIndex; j++) {
        QCLocationModel *model = dataArray[j];
        CLLocationCoordinate2D temLocationCoordinate =  AMapCoordinateConvert(CLLocationCoordinate2DMake([model.lat floatValue], [model.lng floatValue]), AMapCoordinateTypeGPS);
        AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:temLocationCoordinate.latitude
                                                          longitude:temLocationCoordinate.longitude];
        [wayArray addObject:geoPoint];
        
    }
    if (wayArray.count) {
        navi.waypoints = wayArray;
    }
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:navi];
}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;

    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;

    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}

#pragma mark - action handling
- (void)addAction:(NSArray *)dataArr
{
//    self.infoArray = dataArr.mutableCopy;
    [dataArr enumerateObjectsUsingBlock:^(QCLocationModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.idx = [NSString stringWithFormat:@"%lu",idx+1];
        CLLocationCoordinate2D randomCoordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake([obj.lat floatValue], [obj.lng floatValue]), AMapCoordinateTypeGPS);
        [self addAnnotationWithCooordinate:randomCoordinate locationModel:obj];
    }];
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations animated:YES];
    
}
#pragma mark - Utility

-(void)addAnnotationWithCooordinate:(CLLocationCoordinate2D)coordinate locationModel:(QCLocationModel *)locationModel
{
       MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
      annotation.coordinate = coordinate;
      annotation.title    = locationModel.idx;
      [self.annotations addObject:annotation];
}

/* 清空地图上已有的路线. */
- (void)clear
{
    [self.mapView removeAnnotations:self.annotations];
    [self.naviRoute removeFromMapView];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.annotations removeAllObjects];
    [self.infoArray removeAllObjects];
}


#pragma mark - MAMapViewDelegate
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{

    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;

        UIColor *color = [UIColor colorWithRed:29/256.0 green:83/256.0 blue:206/256.0 alpha:0.6];
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        
        return polylineRenderer;
    }
    
    return nil;
}
- (void)dealloc{
    
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if (!self.annotations.count) {
        if ([annotation isKindOfClass:[MAUserLocation class]])
        {
            static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
            MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:userLocationStyleReuseIndetifier];
            }

            annotationView.image = [UIImage imageNamed:@"userPosition"];

            self.userLocationAnnotationView = annotationView;

            return annotationView;
        }

        return nil;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        if ([annotation.title isEqualToString: RoutePlanningViewControllerStartTitle]||[annotation.title isEqualToString: RoutePlanningViewControllerDestinationTitle]) {
            static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";

            MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
            if (poiAnnotationView == nil)
            {
                poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:routePlanningCellIdentifier];
            }
            poiAnnotationView.canShowCallout = NO;
            poiAnnotationView.image = nil;
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
            }
            /* 起点. */

            return poiAnnotationView;
        }else{
            static NSString *customReuseIndetifier = @"customReuseIndetifier";

                    CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];

            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
                // must set to NO, so we can show the custom callout view.
                annotationView.canShowCallout = NO;
                annotationView.draggable   = NO;
    //            annotationView.calloutOffset = CGPointMake(0, -5);
                annotationView.portrait = [UIImage imageNamed:@"zuobiao1_icon_del"];
            }
            int idx = annotation.title.intValue-1;
            if (idx<self.infoArray.count) {
                QCLocationModel *model = self.infoArray[idx];
                annotationView.locationModel = model;
                annotationView.locationType = model.customvo?QCLocationAnnotationTypeVisit:QCLocationAnnotationTypeNormal;
                annotationView.portrait = [UIImage imageNamed:model.customvo?@"zuobiao1_icon_del":@"zuobiao1_icon_del"];
            }
            return annotationView;
        }

    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    /* Adjust the map center in order to show the callout view completely. */
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* Calculate the offset to make the callout view show up. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];

            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);

            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];

            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
        
    }
}
- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
    
    self.currentCourse = 0;
    
    if (response.count > 0)
    {
        [self presentCurrentCourse];
    }
}
/* 展示当前路线方案. */
- (void)presentCurrentCourse
{
    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[0] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.route.origin.latitude longitude:self.route.destination.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.route.origin.latitude longitude:self.route.destination.longitude]];
    [self.naviRoute addToMapView:self.mapView];
    
    // 缩放地图使其适应polylines的展示.
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                           animated:YES];
}

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSMutableArray *)annotations{
    if (!_annotations) {
        _annotations = [NSMutableArray arrayWithCapacity:0];
    }
    return _annotations;
}
- (NSMutableArray *)infoArray{
    if (!_infoArray) {
        _infoArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _infoArray;
}
@end
