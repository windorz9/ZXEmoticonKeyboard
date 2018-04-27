//
//  ZXEmotionToolBar.swift
//  表情键盘
//
//  Created by windorz on 2018/3/17.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit

@objc protocol ZXEmotionToolBarDelegate: NSObjectProtocol {
    
    func emotionToolBarDidSelectedItemIndex(toolbar: ZXEmotionToolBar, index: Int)
    
}

class ZXEmotionToolBar: UIView {
    
    weak var delegate: ZXEmotionToolBarDelegate?
    
    var selectedIndex: Int = 0 {
        
        didSet {
            
            // 1. 取消所有按钮的选中状态
            for btn in subviews as! [UIButton] {
                btn.isSelected = false
            }
            
            // 2. 设置传递进来的 index 的按钮变为选中状态
            (subviews[selectedIndex] as! UIButton).isSelected = true
            
        }
        
        
    }

    override func awakeFromNib() {
        
        setupUI()
    }
    
    override func layoutSubviews() {
        // 纯代码都在这里进行布局, 因为适配设备的不同
        
        // 布局所有的按钮
        let count = subviews.count
        let width = bounds.width / CGFloat(count)
        let rect = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        
        for (i, btn) in subviews.enumerated() {
            
            btn.frame = rect.offsetBy(dx: CGFloat(i) * width, dy: 0)
        }
    }
    
    // MARK: - 监听点击按钮的方法
    /// 点分组按钮
    @objc private func clickItem(button: UIButton) {
        
        delegate?.emotionToolBarDidSelectedItemIndex(toolbar: self, index: button.tag)
        
    }
    
    

}

private extension ZXEmotionToolBar {
    
    func setupUI() {
        
        // 0. 获取表情包单例
        let manager = ZXEmoticonManager.shared
        
        // 从单例的表情组数据获取分组名称, 设置按钮
        for (i, p) in manager.packages.enumerated() {
            
            // 1> 实例化按钮
            let btn = UIButton()
            
            // 2> 设置按钮状态
            btn.setTitle(p.groupName, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitleColor(UIColor.darkGray, for: .highlighted)
            btn.setTitleColor(UIColor.darkGray, for: .selected)
            
            btn.sizeToFit()
            
            // 设置按钮的背景图片
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameHL = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            
            var image = UIImage(named: imageName, in: manager.bundle, compatibleWith: nil)
            var imageHL = UIImage(named: imageNameHL, in: manager.bundle, compatibleWith: nil)
            
            // 将图片进行纯代码拉伸
            let size = image?.size ?? CGSize()
            let insert = UIEdgeInsets(top: size.height * 0.5,
                                      left: size.width * 0.5,
                                      bottom: size.height * 0.5,
                                      right: size.width * 0.5)
            // 原理就是拉伸用最中间的一个像素点进行填充
            image = image?.resizableImage(withCapInsets: insert)
            imageHL = imageHL?.resizableImage(withCapInsets: insert)
            
            
            
            btn.setBackgroundImage(image, for: .normal)
            btn.setBackgroundImage(imageHL, for: .highlighted)
            btn.setBackgroundImage(imageHL, for: .selected)
            
            // 3> 添加按钮
            addSubview(btn)
            
            // 4> 设置按钮的 tag
            btn.tag = i
            
            // 5> 添加按钮的监听方法
            btn.addTarget(self, action: #selector(clickItem), for: .touchUpInside)
        }
        
        // 默认选中第 0 个按钮
        (subviews[0] as! UIButton).isSelected = true
        
        
        
    }
    
    
    
}
