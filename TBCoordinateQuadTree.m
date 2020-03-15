//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by tomlu on 9/27/18.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"

#import "MapPlayerInfo.h"  //玩转数据



typedef struct TBHotelInfo {
    char* hotelName;
    char* hotelPhoneNumber;
} TBHotelInfo;




TBQuadTreeNodeData TBDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@","];
    double latitude = [components[1] doubleValue];
    double longitude = [components[0] doubleValue];

    TBHotelInfo* hotelInfo = malloc(sizeof(TBHotelInfo));

    NSString *hotelName = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);

    NSString *hotelPhoneNumber = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);

    return TBQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
}

//将我们的模型转化为TB结构体
TBQuadTreeNodeData TBDataFromWZData(MapPlayerInfo* playerInfo)
{
    
    MapPlayerInfo* newPlayerInfo= [[MapPlayerInfo alloc]init];
    newPlayerInfo.id = [[NSNumber alloc]initWithInt:playerInfo.id.intValue];
    newPlayerInfo.sexy = [[NSString alloc]initWithString:playerInfo.sexy];
    newPlayerInfo.latitude = [[NSString alloc]initWithString:playerInfo.latitude];
    newPlayerInfo.longitude = [[NSString alloc]initWithString:playerInfo.longitude];
    newPlayerInfo.avatar = [[NSString alloc]initWithString:playerInfo.avatar];
    
    TBQuadTreeNodeData newData = TBQuadTreeNodeDataMake(playerInfo.latitude.doubleValue, playerInfo.longitude.doubleValue, (void*)CFBridgingRetain(newPlayerInfo));
    
    return newData;
    
//    return TBQuadTreeNodeDataMake(playerInfo.latitude.doubleValue, playerInfo.longitude.doubleValue, CFBridgingRetain(tempPlayerInfo));
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));

    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;

    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;

    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));

    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));

    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);

    switch (zoomLevel) {
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;
        case 20:
            return 17;
            
        default:
            return 88;
    }
    
//    switch (zoomLevel) {
//        case 13:
//        case 14:
//        case 15:
//            return 64;
//        case 16:
//        case 17:
//        case 18:
//            return 32;
//        case 19:
//            return 16;
//
//        default:
//            return 88;
//    }
}

@implementation TBCoordinateQuadTree

//lhf 创建四叉树
- (void)buildTreeWithDatas:(NSArray<MapPlayerInfo*>*)datas
{
    @autoreleasepool {
        int count = datas.count;
        //在ios平台中一个指针长度变成了8
        //pNodeData 指向链表datas首元素的header指针
        TBQuadTreeNodeData* pNodeData =  malloc(sizeof(TBQuadTreeNodeData) * count);
        
        for (NSInteger i = 0; i < count; i++) {
            MapPlayerInfo* playerInfo = datas[i];
            //指针指向了创建出来的playerInfo对象(地址)
            TBQuadTreeNodeData newData = TBDataFromWZData(playerInfo);
//            NSLog(@"%f",data);
            pNodeData[i] = newData;
            NSLog(@"%@",pNodeData[i].data);
        }
            
        //准备盒子数据
        double x0 = 0;
        double y0 = 0;
        
        double xN = 0;
        double yN = 0;
        
        double spaceX = 40;//72 - 19;
        double spaceY = 40;//166 - 53;
        
        x0 = pNodeData[0].x - spaceX/2;
        y0 = pNodeData[0].y - spaceY/2;
        
        xN = pNodeData[0].x + spaceX/2;
        yN = pNodeData[0].y + spaceY/2;
        
        for(int i = 0; i < count; i++) {
            MapPlayerInfo* info = (__bridge MapPlayerInfo *)(pNodeData[i].data);
            NSLog(@"%@",info.id);
        }
        
        //第一个框很重要 需要传入第一个节点数据中的经纬度创建这个框
        TBBoundingBox world = TBBoundingBoxMake(x0,y0,xN,yN);
//        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
        
        //创建四叉树
        _root = TBQuadTreeBuildWithData(pNodeData, count, world, 4);
        NSLog(@"1");
    }
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;

    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            __block MapPlayerInfo* mapPlayerInfo = nil;
           
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
                mapPlayerInfo = (__bridge MapPlayerInfo*)data.data;
            });

            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                annotation.mapPlayerInfo = mapPlayerInfo;
                [clusteredAnnotations addObject:annotation];
            }

            if (count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                annotation.mapPlayerInfo = mapPlayerInfo;
                [clusteredAnnotations addObject:annotation];
            }
        }
    }

    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end
