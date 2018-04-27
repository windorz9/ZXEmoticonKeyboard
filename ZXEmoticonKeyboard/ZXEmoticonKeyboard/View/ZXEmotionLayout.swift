//
//  ZXEmotionLayout.swift
//  表情键盘
//
//  Created by windorz on 2018/3/17.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit

class ZXEmotionLayout: UICollectionViewFlowLayout {

    // 就是 OC 当中的 prepare 
    override func prepare() {
        super.prepare()
        
        
        // 在此方法当中, collectionView 的大小已经确定了
        guard let collectionView = collectionView else {
            return
        }
        
        itemSize = collectionView.bounds.size
        
        // 可直接在 xib 当中进行设置
//        minimumLineSpacing = 0
//        minimumInteritemSpacing = 0
        
        
        // 设定滚动的方向
        // 水平方向滚动, cell 垂直方向布局
        // 垂直方向滚动, cell 水平方向布局
        // 有点反人类, 当我们想水平滚动的时候, 表情却只能竖着放, 所以我们需要做下调整, 不能使用一个 cell 放一个表情, 而是用一个和 collectionView 等大的 cell 一次放置20个, 9宫格那样, 3 * 7 最后一个位置放一个删除按钮.
        scrollDirection = .horizontal
    }
}
