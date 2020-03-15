//
//  TBClusterAnnotation.m
//  WZ
//
//  Created by HaiFang Luo on 2018/12/21.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import "TBClusterAnnotation.h"

@implementation TBClusterAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.count = count;
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

@end
