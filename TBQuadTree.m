//
//  TBQuadTree.m
//  TBQuadTree
//
//  Created by tomlu on 9/27/18.
//  Copyright (c) 2018 tomlu. All rights reserved.
//

#import "TBQuadTree.h"

#pragma mark - Constructors

TBQuadTreeNodeData TBQuadTreeNodeDataMake(double x, double y, void* data)
{
    TBQuadTreeNodeData d; d.x = x; d.y = y; d.data = data;
    return d;
}

TBBoundingBox TBBoundingBoxMake(double x0, double y0, double xf, double yf)
{
    TBBoundingBox bb;
    bb.x0 = x0; bb.y0 = y0; bb.xf = xf; bb.yf = yf;
    return bb;
}

TBQuadTreeNode* TBQuadTreeNodeMake(TBBoundingBox boundary, int bucketCapacity)
{
    TBQuadTreeNode* node = malloc(sizeof(TBQuadTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;

    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->count = 0;
    node->points = malloc(sizeof(TBQuadTreeNodeData) * bucketCapacity);

    return node;
}

#pragma mark - Bounding Box Functions
//判断是否含有数据
bool TBBoundingBoxContainsData(TBBoundingBox box, TBQuadTreeNodeData data)
{
    bool containsX = box.x0 <= data.x && data.x <= box.xf;
    bool containsY = box.y0 <= data.y && data.y <= box.yf;

    return containsX && containsY;
}

bool TBBoundingBoxIntersectsBoundingBox(TBBoundingBox b1, TBBoundingBox b2)
{
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0);
}

#pragma mark - Quad Tree Functions

void TBQuadTreeNodeSubdivide(TBQuadTreeNode* node)
{
    //取出节点的盒子数据
    TBBoundingBox box = node->boundingBox;

    double xMid = (box.xf + box.x0) / 2.0;
    double yMid = (box.yf + box.y0) / 2.0;

    //创建新的盒子
    TBBoundingBox northWest = TBBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = TBQuadTreeNodeMake(northWest, node->bucketCapacity);

    TBBoundingBox northEast = TBBoundingBoxMake(xMid, box.y0, box.xf, yMid);
    node->northEast = TBQuadTreeNodeMake(northEast, node->bucketCapacity);

    TBBoundingBox southWest = TBBoundingBoxMake(box.x0, yMid, xMid, box.yf);
    node->southWest = TBQuadTreeNodeMake(southWest, node->bucketCapacity);

    TBBoundingBox southEast = TBBoundingBoxMake(xMid, yMid, box.xf, box.yf);
    node->southEast = TBQuadTreeNodeMake(southEast, node->bucketCapacity);
}


//四叉树 插入节点
bool TBQuadTreeNodeInsertData(TBQuadTreeNode* node, TBQuadTreeNodeData data)
{
    //判断是否包含数据 没有数据不插入
    if (!TBBoundingBoxContainsData(node->boundingBox, data)) {
        return false;
    }

    //如果节点的周围节点数 小于 该节点的盒子容量
    if (node->count < node->bucketCapacity) {
        node->points[node->count++] = data;
        return true;
    }

    //如果节点上方无节点 创建子节点
    if (node->northWest == NULL) {
        TBQuadTreeNodeSubdivide(node);
    }

    //递归 分别四个方向插入节点
    if (TBQuadTreeNodeInsertData(node->northWest, data)) return true;
    if (TBQuadTreeNodeInsertData(node->northEast, data)) return true;
    if (TBQuadTreeNodeInsertData(node->southWest, data)) return true;
    if (TBQuadTreeNodeInsertData(node->southEast, data)) return true;

    return false;
}

void TBQuadTreeGatherDataInRange(TBQuadTreeNode* node, TBBoundingBox range, TBDataReturnBlock block)
{
    if (!TBBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }

    for (int i = 0; i < node->count; i++) {
        if (TBBoundingBoxContainsData(range, node->points[i])) {
            block(node->points[i]);
        }
    }

    if (node->northWest == NULL) {
        return;
    }

    TBQuadTreeGatherDataInRange(node->northWest, range, block);
    TBQuadTreeGatherDataInRange(node->northEast, range, block);
    TBQuadTreeGatherDataInRange(node->southWest, range, block);
    TBQuadTreeGatherDataInRange(node->southEast, range, block);
}

void TBQuadTreeTraverse(TBQuadTreeNode* node, TBQuadTreeTraverseBlock block)
{
    block(node);

    if (node->northWest == NULL) {
        return;
    }

    TBQuadTreeTraverse(node->northWest, block);
    TBQuadTreeTraverse(node->northEast, block);
    TBQuadTreeTraverse(node->southWest, block);
    TBQuadTreeTraverse(node->southEast, block);
}

//使用节点创建四叉树根节点 函数1

TBQuadTreeNode* TBQuadTreeBuildWithData(TBQuadTreeNodeData* data, int count, TBBoundingBox boundingBox, int capacity)
{
    
    // 四叉树的根节点
    //使用 举行boundingBox 和 容量 初始化一个空节点
    TBQuadTreeNode* root = TBQuadTreeNodeMake(boundingBox, capacity);
    
    //从根节点开始，通过数据data 不断插入新节点
    for (int i = 0; i < count; i++) {
        //插入节点
        TBQuadTreeNodeInsertData(root, data[i]);
    }

    return root;
}

void TBFreeQuadTreeNode(TBQuadTreeNode* node)
{
    if (node->northWest != NULL) TBFreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) TBFreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) TBFreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) TBFreeQuadTreeNode(node->southEast);

    for (int i=0; i < node->count; i++) {
        free(node->points[i].data);
    }
    free(node->points);
    free(node);
}
