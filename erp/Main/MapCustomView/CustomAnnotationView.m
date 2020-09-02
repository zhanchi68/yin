//
//  CustomAnnotationView.m
//  erp
//
//  Created by apple on 2020/8/15.
//  Copyright © 2020 sdqc56. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"
#define kWidth  80.f
#define kHeight 60.f

#define kHoriMargin 8.f
#define kVertMinMargin 4.f
#define kVertMargin 15.f
#define kLabelMargin 15.f

#define kPortraitWidth  30.f
#define kPortraitHeight 30.f

#define kCalloutWidth   350.0
#define kCalloutHeight  128.0
#define kLabelHeight 16

#define kLabelFont 10
#define KCornerRadius 11.5
#define kNormalLabelHeight 23
@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *visitLab;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *telLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *devLab;
@property (nonatomic, strong) UIView *nameBackgroundView;
@property (nonatomic, strong) UILabel *numLab;
@end

@implementation CustomAnnotationView

@synthesize calloutView         =_calloutView;
@synthesize portraitImageView   = _portraitImageView;
@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action

- (void)btnAction
{
//    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
//
//    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
}

#pragma mark - Override

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        [self addSubview:self.calloutView];
        _visitLab.text = [NSString stringWithFormat:@"%@%@",@"拜访公司：",_locationModel.customvo[@"name"]];
        _nameLab.text = [NSString stringWithFormat:@"%@%@",@"姓        名：",_locationModel.employee[@"name"]];
        _telLab.text = [NSString stringWithFormat:@"%@%@",@"手  机  号：",_locationModel.employee[@"phone"]];
        _timeLab.text = [NSString stringWithFormat:@"%@%@",@"上报时间：",_locationModel.addtime];
        _devLab.text = [NSString stringWithFormat:@"%@%@-%@",@"设备信息：",_locationModel.brand,_locationModel.model];
    }
    else
    {
        [self.calloutView removeFromSuperview];
        
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
//        self.backgroundColor = [UIColor grayColor];
        
        /* Create portrait image view and add to view hierarchy. */
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kWidth-kPortraitWidth)*.5, 0, kPortraitWidth, kPortraitHeight)];
        [self addSubview:self.portraitImageView];
        
        /* Create name label. */
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(self.portraitImageView.frame),kWidth,kNormalLabelHeight)];
        self.nameLabel.textAlignment    = NSTextAlignmentCenter;
        self.nameLabel.textColor        = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
        self.nameLabel.font             = [UIFont systemFontOfSize:14];
        [self addSubview:self.nameLabel];
    }
    
    return self;
}
- (void)setLocationModel:(QCLocationModel *)locationModel{
    _locationModel = locationModel;
    BOOL isTrack = _isTrackType == QCLocationAnnotationTypeTrack;
    NSString *tempName = isTrack ? @"" : [NSString stringWithFormat:@".%@",locationModel.employee[@"name"]];
    NSString *nameStr = [NSString stringWithFormat:@"%@%@",locationModel.idx,tempName];
    self.name = nameStr;
   
    NSString *imageName = @"zuobiao1_icon_del";
   
   self.portrait = [UIImage imageNamed:imageName];
    
}




@end
