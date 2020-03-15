//
//  TBClusterAnnotationView.h
//  TBAnnotationClustering
//
//  Created by tomlu on 9/27/18.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapPlayerInfo.h"

@protocol CustomAnnotationViewDelegate <NSObject>

@optional
//用户头像被点击
-(void) coustomAnnontationViewUserHeadIconClicked:(MapPlayerInfo*)playerInfo;
@end

@interface TBClusterAnnotationView : MAAnnotationView

//统计相邻锚点个数  max 为4
@property (assign, nonatomic) NSUInteger count;

@property(nonatomic,strong)MapPlayerInfo* mapPlayerInfo;
@property(nonatomic,assign)id<CustomAnnotationViewDelegate> delegate;

@end
