//
//  ZXEmotionCell.swift
//  表情键盘
//
//  Created by windorz on 2018/3/17.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit

// 创建协议
@objc protocol ZXEmoticonCellDelegate: NSObjectProtocol {
    
    func emotionCellDidSelectdEmotion(cell: ZXEmotionCell, em: ZXEmoticon?)
}

// 表情页面 cell

// - 每一个 cell 就是和 collectionView 一样大小.
// - 每一个 cell 中使用9宫格布局的算法, 自行添加20个表情外加一个删除按钮.

class ZXEmotionCell: UICollectionViewCell {
    
    // 创建代理
    weak var delegate: ZXEmoticonCellDelegate?

    
    var emotions: [ZXEmoticon]? {
        didSet {
            
            for btn in contentView.subviews {
                
                btn.isHidden = true
            }
            
            contentView.subviews.last?.isHidden = false
            
            for (i, em) in (emotions ?? []).enumerated() {
                
                if let btn = contentView.subviews[i] as? UIButton {
                    
                    // 如果图像为 nil, 需要清空图像, 避免复用
                    btn.setImage(em.imgae, for: .normal)
                    
                    // 如果 emoji 为空, 就需要清空title, 避免复用.
                    btn.setTitle(em.emojo, for: .normal)
                    btn.isHidden = false
                    
                }
                
            }
            
        }
    }
    
    // 表情选择提示视图
    private lazy var tipView = ZXEmotionTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func awakeFromNib() {
//
//        setupUI()
//    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let window = newWindow else {
            return
        }
        
        // 将视图添加到窗口上面
        // 提示: 在 iOS 6.0 之前, 很多程序员都喜欢把控件往窗口上加,
        // 在现在的开发当中, 如果有地方, 就不要使用窗口.
        
        window.addSubview(tipView)
        tipView.isHidden = true
    }
    
    // MARK: 方法监听
    @objc private func selectedEmotionButton(button: UIButton) {
        
        // 一个单元格上面一共有 21个按钮 20个表情加一个删除按钮 tag 0~20
        // emoticons 数组 只有20个模型 0~19
        
        // 取 tag 值
        let tag = button.tag
        
        var em: ZXEmoticon?
        
        if tag < (emotions?.count)! {
            em = emotions?[tag]
        }
        
//        print(em)
        delegate?.emotionCellDidSelectdEmotion(cell: self, em: em)
    
    }
    
    @objc func longGesture(gesture: UILongPressGestureRecognizer) {
        
//        // 测试添加提示视图
//        addSubview(tipView)
        // 1> 获取触摸的位置
        let location = gesture.location(in: self)
        
        // 2> 获取触摸位置对应的按钮
        guard let button = buttonwithLocation(location: location) else {
            // 按钮超出边界, 也需要隐藏当前的tipView
            tipView.isHidden = true
            return
        }
        
        // 3> 处理手势状态
        // 在处理手势状态时, 不要试图一次就将所要的状态处理完毕, 不利于调试.
        switch gesture.state {
        case .began, .changed:
            tipView.isHidden = false
            
            // 坐标系的转换
            // 将按钮参照cell的坐标系, 转换到 window 的坐标位置.
            let center = self.convert(button.center, to: window)
            // 设置提示视图的位置
            tipView.center = center
            
            // 设置提示视图的表情模型
            if button.tag < (emotions?.count)! {
                tipView.emoticon = emotions?[button.tag]
            }
            
        case .ended:
            tipView.isHidden = true
            // 设置完毕 当手指离开时, 应该显示当前选中的文本
            selectedEmotionButton(button: button)
        case .cancelled, .failed:
            tipView.isHidden = true
        default:
            break
        }
        
        // print(button)
        
    }
    
    private func buttonwithLocation(location: CGPoint) -> UIButton? {
        
        // 遍历当前cell的子视图的所有的按钮子视图
        for btn in contentView.subviews as! [UIButton] {
            
            // 删除按钮和隐藏的按钮都需要进行处理
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                
                return btn
            }
        }
        
        return nil
    }

}

// MARK: 界面设置
private extension ZXEmotionCell {
    
    // 从 xib 加载, bounds 是 xib 当中定义的大小, 而不是我们 size 的大小.
    // 从纯代码创建, bounds 就是布局属性当中的 itemSize 的大小.
    func setupUI() {
        
        let rowCount = 3
        let colCount = 7
        
        // 左右间距
        let leftMargin: CGFloat = 8
        // 底部间距, 为pageControl 控件留出位置
        let bottomMargin: CGFloat = 16
        
        let w = (bounds.width - 2 * leftMargin) / CGFloat(colCount)
        let h = (bounds.height - bottomMargin) / CGFloat(rowCount)
        // 连续创建 21 个按钮
        
        for i in 0..<21 {
            
            let row = i / colCount
            let col = i % colCount
    
            let btn = UIButton()
            // 设置按钮的大小
            let x = leftMargin + w * CGFloat(col)
            let y = h * CGFloat(row)
            
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
//            btn.backgroundColor = UIColor.red
        
            // 设置按钮的title 字体大小 lineHeight 基本上和图片的大小差不多.
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
//            btn.isHidden = true
            // 设置按钮的tag 值 用来区分 删除按钮和点击的什么表情
            btn.tag = i
            // 为按钮添加点击事件
            btn.addTarget(self, action: #selector(selectedEmotionButton(button:)), for: .touchUpInside)
            
            contentView.addSubview(btn)
        
            
        }
        
        let bundle = ZXEmoticonManager.shared.bundle
        let image = UIImage(named: "compose_emotion_delete", in: bundle, compatibleWith: nil)
        let imageHL = UIImage(named: "compose_emotion_delete_highlighted", in: bundle, compatibleWith: nil)
        
        let removeButton = contentView.subviews.last as! UIButton
        removeButton.setImage(image, for: .normal)
        removeButton.setImage(imageHL, for: .highlighted)
        
        
        // 添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        
        longPress.minimumPressDuration = 0.1
        
        addGestureRecognizer(longPress)
        
    }
    
    
}
