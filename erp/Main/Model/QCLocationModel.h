//
//  QCLocationModel.h
//  erp
//
//  Created by apple on 2020/8/18.
//  Copyright © 2020 sdqc56. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCLocationModel : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *employeeid;
@property (nonatomic, strong) NSDictionary *employee;
@property (nonatomic, strong) NSDictionary *customvo;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *lng;
@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *edition;
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *online;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *customName;
@property (nonatomic, copy) NSString *idx;
@end

NS_ASSUME_NONNULL_END
