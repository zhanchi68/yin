//
//  CustomAnnotationView.h
//  erp
//
//  Created by apple on 2020/8/15.
//  Copyright © 2020 sdqc56. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCLocationModel.h"
@import MAMapKit;


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,QCLocationAnnotationType){
    QCLocationAnnotationTypeNormal = 0,//员工定位信息类型
    QCLocationAnnotationTypeVisit, //定位拜访信息类型
    QCLocationAnnotationTypeTrack  //轨迹信息类型
    
};
@interface CustomAnnotationView : MAAnnotationView
@property (nonatomic,assign) QCLocationAnnotationType locationType;
@property (nonatomic,assign) QCLocationAnnotationType isTrackType;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *portrait;

@property (nonatomic, strong) QCLocationModel *locationModel;

@property (nonatomic, strong) UIImageView *calloutView;

@end

NS_ASSUME_NONNULL_END
