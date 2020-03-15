//
//  TBClusterAnnotation.h
//  WZ
//
//  Created by HaiFang Luo on 2018/12/21.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapPlayerInfo.h"
#import <MAMapKit/MAMapKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TBClusterAnnotation : MAPointAnnotation

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) NSInteger count;

@property (strong, nonatomic) MapPlayerInfo* mapPlayerInfo;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;
@end

NS_ASSUME_NONNULL_END
