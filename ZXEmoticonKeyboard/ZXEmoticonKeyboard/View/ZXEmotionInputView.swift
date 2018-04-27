//
//  ZXEmotionInputView.swift
//  表情键盘
//
//  Created by windorz on 2018/3/17.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit

// 可重用的标识符
private let cellId = "cellId"

// 表情输入视图
class ZXEmotionInputView: UIView {

    
    @IBOutlet weak var collectionView: UICollectionView!
    /// 工具栏
    @IBOutlet weak var toolBar: ZXEmotionToolBar!
    /// 分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    // 创建闭包属性 - 选中表情闭包回调属性
    private var selectedEmotionCallBack: ((ZXEmoticon?)->())?
    
    
    /// 加载并且返回输入视图
    ///
    /// - Returns: 输入视图
    class func inputView(selectedEmoticon: @escaping (ZXEmoticon?)->()) -> ZXEmotionInputView {
        
        // 当闭包不是这这里执行的话, 我们需要创建一个闭包属性进行接收
        
        let nib = UINib(nibName: "ZXEmotionInputView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! ZXEmotionInputView
        
        // 记录闭包
        v.selectedEmotionCallBack = selectedEmoticon
        
        return v
        
        
    }
    
    override func awakeFromNib() {
        // 注册单元格
        collectionView.register(ZXEmotionCell.self, forCellWithReuseIdentifier: cellId)
//        let nib = UINib(nibName: "ZXEmotionCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        // 从xib加载的toolBar 在这里设置代理
        toolBar.delegate = self
        
        // 给 pageControl 设置图片
        let bundle = ZXEmoticonManager.shared.bundle
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else {
            
            return
        }
        
//        // 这样设置会出现偏差, 图片没有完全填充 通过使用runtime 来获取所有的成员变量.
//        pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
//        pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
        
        // 然后使用 kvc 来设置 私有成员变量
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
        
    }

}

extension ZXEmotionInputView: ZXEmotionToolBarDelegate {
    
    
    func emotionToolBarDidSelectedItemIndex(toolbar: ZXEmotionToolBar, index: Int) {
        
        let indexPath = IndexPath(item: 0, section: index)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        toolBar.selectedIndex = index
        
    }
    
    
}


// MARK: - UICollectionViewDelegate
extension ZXEmotionInputView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 1. 获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        // 2. 获取当前显示的 cell 的 indexPath
        let paths = collectionView.indexPathsForVisibleItems
        
        // 3. 判断中心点 位于哪一个 indexPath上, 在哪一个页面上
        var targetIndexpath: IndexPath?
        
        for indexPath in paths {
            
            // 1> 根据indexPath 获取 cell
            let cell = collectionView.cellForItem(at: indexPath)
            
            // 2> 判断中心点位于哪个 cell 上
            if cell?.frame.contains(center) == true {
                
                targetIndexpath = indexPath
                
                break
            }
        }
        
        guard let target = targetIndexpath else {
            return
        }
        
        // 4. 判断是否找到 目标的 indexPath
        // indexPath.section 对应的就是分组
        toolBar.selectedIndex = target.section
        
        // 5. 设置分页控件
        // 1> 设置总页数
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
        
        // 2> 在 awakefromnib 里面给 pageControl 设置图片
        
        
    }
    
}

// MARK: - UICollectionViewDataSource
extension ZXEmotionInputView: UICollectionViewDataSource {
    
    // 分组数量 - 返回表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ZXEmoticonManager.shared.packages.count
    }
    
    // 返回每个分组当中的表情'页'的数量
    // 每个分组表情包当中, 表情页的数量, emotions / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ZXEmoticonManager.shared.packages[section].numberOfPages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1. 取 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ZXEmotionCell
        
        
        // 2. 设置 cell
        // 传递对应页面的表情数组
        cell.emotions = ZXEmoticonManager.shared.packages[indexPath.section].emotions(page: indexPath.item)
        
        cell.delegate = self
        // 3. 返回 cell
        return cell
    }
    
    
    
}

// MARK: ZXEmoticonCellDelegate
extension ZXEmotionInputView: ZXEmoticonCellDelegate {
    
    
    func emotionCellDidSelectdEmotion(cell: ZXEmotionCell, em: ZXEmoticon?) {
//        print(em)
        
        // 在这里执行闭包
        selectedEmotionCallBack?(em)
        
        // 添加最近使用的表情
        guard let em = em else {
            return
        }
        // 但是要注意, 当我们点击最近表情 也就是第 0 组的表情时, 这里不添加表情也不进行刷新
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        
        if indexPath.section == 0 {
            return
        }
        
        ZXEmoticonManager.shared.recentEmoticon(em: em)
        
        // 每次点完表情后刷新第 0 组
        var indexSet = IndexSet()
        indexSet.insert(0)
        
        collectionView.reloadSections(indexSet)
        
        
    }
    
    
    
}
