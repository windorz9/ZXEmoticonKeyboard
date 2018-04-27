//
//  ZXEmotionTipView.swift
//  WMWeibo
//
//  Created by windorz on 2018/3/21.
//  Copyright © 2018年 张雄. All rights reserved.
//

import UIKit
import pop

class ZXEmotionTipView: UIImageView {
    
    // 记录上一个表情
    private var preEmticon: ZXEmoticon?
    
    // 将表情数据传入
    var emoticon: ZXEmoticon? {
        didSet {
            
            if emoticon == preEmticon {
                return
            }
            
            //  记录当前的表情
            preEmticon = emoticon
            
            // 设置表情数据
            tipButton.setTitle(emoticon?.emojo, for: .normal)
            tipButton.setImage(emoticon?.imgae, for: .normal)
            
            // 为按钮添加动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = 30
            anim.toValue = 8
            
            anim.springBounciness = 20
            anim.springSpeed = 20
            
            tipButton.layer.pop_add(anim, forKey: nil)
            
//            print("设置表情")
            
            
        }
        
    }

    // 私有控件
    private lazy var tipButton = UIButton()
    
    /// MARK: 构造函数
    init() {
        // emoticon_keyboard_magnifier@2x
        let bundle = ZXEmoticonManager.shared.bundle
        let image = UIImage(named: "emoticon_keyboard_magnifier", in: bundle, compatibleWith: nil)
        
        // [[UIImageView alloc] initWithImage: image] => 会根据图像大小设置图像视图的大小.
        super.init(image: image)
        
        // 设置锚点
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
        
        // 添加上面的预览按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        tipButton.frame = CGRect(x: 0, y: 8, width: 36, height: 36)
        tipButton.center.x = bounds.width * 0.5

        
        // tipButton.setTitle("😀", for: .normal)
        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        addSubview(tipButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
