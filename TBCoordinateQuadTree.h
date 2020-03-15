//
//  TBCoordinateQuadTree.h
//  TBAnnotationClustering
//
//  Created by tomlu on 9/27/18.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBQuadTree.h"
#import "MapPlayerInfo.h" //地图用户模型

@interface TBCoordinateQuadTree : NSObject

@property (assign, nonatomic) TBQuadTreeNode* root;
@property (strong, nonatomic) MKMapView *mapView;

//构建四叉树
- (void)buildTreeWithDatas:(NSArray<MapPlayerInfo*>*)datas;

//锚点缩放
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;

@end
