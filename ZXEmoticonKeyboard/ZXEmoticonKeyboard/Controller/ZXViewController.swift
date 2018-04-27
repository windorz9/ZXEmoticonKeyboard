//
//  ZXViewController.swift
//  ZXEmoticonKeyboard
//
//  Created by windorz on 2018/4/27.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit

class ZXViewController: UIViewController {
    
    // 文本编辑视图
    @IBOutlet weak var textView: ZXComposeTextView!
    
    // 底部工具栏
    @IBOutlet weak var toolBar: UIToolbar!
    
    // 工具栏底部约束
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    
    // 记录当前设备的键盘高度
    private var keyBoardHeight: CGFloat = 0.0
    
    lazy var emotionView = ZXEmotionInputView.inputView {[weak self] (emotion) in
        
        // 这里发生了循环引用, self 持有 emotionView 这个视图, 视图持有这个闭包, 闭包又持有self 也就是这个控制器, 于是就发生了循环引用. 需要在闭包里面加上 [weak self]
        self?.textView.insertEmoticon(em: emotion)
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()
        setupUI()

        // 监听键盘通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChange),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 激活键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 注销键盘
        textView.resignFirstResponder()
    }
    
    @objc private func keyboardChange(n: Notification) {
        
        
        /**
         print(n.userInfo)
         
         ([
         AnyHashable("UIKeyboardCenterBeginUserInfoKey"):
         NSPoint: {187.5, 796},
         AnyHashable("UIKeyboardIsLocalUserInfoKey"): 1,
         AnyHashable("UIKeyboardCenterEndUserInfoKey"): NSPoint: {187.5, 538},
         AnyHashable("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {375, 258}},
         AnyHashable("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 409}, {375, 258}},
         AnyHashable("UIKeyboardAnimationCurveUserInfoKey"): 7,
         AnyHashable("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 667}, {375, 258}},
         AnyHashable("UIKeyboardAnimationDurationUserInfoKey"): 0.25])
         */
        
        // 1. 目标 rect
        guard let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                return
        }
        
        // 2. 设置底部的约束高度
        let offset = view.bounds.height - rect.origin.y
        
        keyBoardHeight = rect.height
        
        // 3. 更新底部约束
        toolBarBottomCons.constant = -offset
        
        // 4. 处理动画 , 使用我们从 info 中 获取到的键盘弹起的动画的高度.
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    // 通过点击表情按钮切换到表情键盘
    @objc private func emotionKeyboard() {
        
        // textView.inputView 就是文本框的输入视图
        // 如果使用系统默认的键盘, 输入视图就为 nil
        
        // 1> 测试键盘视图 创建一个键盘视图先
        //        // 视图的宽度可以随意设置, 最后肯定是屏幕的宽度.
        //        let keyBoardView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: keyBoardHeight))
        //        keyBoardView.backgroundColor = UIColor.orange
        
        // 2> 设置键盘视图
        textView.inputView = (textView.inputView == nil) ? emotionView : nil
        
        // 3> 刷新键盘视图
        textView.reloadInputViews()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ZXViewController: UITextViewDelegate {
    
    // 文本视图文本变化
    func textViewDidChange(_ textView: UITextView) {
//        sendButton.isEnabled = textView.hasText
    }
    
    
}


private extension ZXViewController {
    
    func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        // setupNavigationBar()
        
        setupToolbar()
    }
    
    
    // 设置工具栏
    func setupToolbar() {
        
        let itemsSettings = [
            ["imageName": "compose_toolbar_picture"],
            ["imageName": "compose_mentionbutton_background"],
            ["imageName": "compose_trendbutton_background"],
            ["imageName": "compose_emoticonbutton_background", "actionName": "emotionKeyboard"],
            ["imageName": "compose_add_background"]
        ]
        
        
        // 遍历
        var items = [UIBarButtonItem]()
        for s in itemsSettings {
            
            guard let imageName = s["imageName"] else {
                continue
            }
            
            let image = UIImage(named: imageName)
            let imageHL = UIImage(named: imageName + "_highlighted")
            
            let btn = UIButton()
            
            btn.setImage(image, for: .normal)
            btn.setImage(imageHL, for: .highlighted)
            
            btn.sizeToFit()
            
            // 判断 actionName
            if let actionName = s["actionName"] {
                
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            // 追加按钮
            items.append(UIBarButtonItem(customView: btn))
            
            // 追加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            
        }
        // 删除末尾弹簧
        items.removeLast()
        
        toolBar.items = items
        
    }
    
    // 设置导航栏
//    func setupNavigationBar() {
//
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", target: self, action: #selector(close))
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
//        // 设置标题视图
//        navigationItem.titleView = titleLabel
//
//        sendButton.isEnabled = false
//
//
//    }
//
    
    
}
