//
//  WMComposeTextView.swift
//  WMWeibo
//
//  Created by windorz on 2018/3/15.
//  Copyright © 2018年 张雄. All rights reserved.
//

import UIKit

class WMComposeTextView: UITextView {

    private lazy var placeholderLabel = UILabel()
    
    // 返回将 textView 对应的纯文本的字符串[将属性文本转换为纯文字]
    var emoticonText: String {
        
        // 1. 获取textView当中的属性文本
        guard let attrStr = attributedText else {
            
            return ""
        }
        
        
        // 2. 需要获取到属性文本中的图片 [附件 Attachment]
        /**
         1> 遍历范围
         2> 选项 []
         3> 闭包
         */
        // 123图片123 -> 被分成3部分 同时生成对应的字典和对应的range
        
        var result = String()
        attrStr.enumerateAttributes(in: NSRange(location: 0, length: attrStr.length), options: [], using: { (dic, range, _) in
            //            print(dic[NSAttributedStringKey.attachment])
            //            print(range)
            // 如果字典当中 dic[NSAttributedStringKey.attachment] 不为nil就说明是 图片 否则就是文本
            
            if let attachment = dic[NSAttributedStringKey.attachment] as? ZXEmoticonTextAttachment {
                
                //                print("图片\(attachment)")
                result += attachment.chs ?? ""
                
            } else {
                
                let subStr = (attrStr.string as NSString).substring(with: range)
                
                result += subStr
            }
            
        })
        
        
        return result
    }
    
    override func awakeFromNib() {
        
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: 监听文本方法
    @objc private func textChange() {
        // 如果有文本就显示, 没文本就隐藏
        placeholderLabel.isHidden = self.hasText
    }
    

}

// MARK: 表情键盘专属方法
extension WMComposeTextView {
    
    /// 向文本里面插入表情符号 [图文混排]
    ///
    /// - Parameter em: 选中的表情符号, nil 表示删除.
    func insertEmoticon(em: ZXEmoticon?) {
        
        // 1. 删除文本
        guard let em = em else {
            // em 为nil 响应删除
            deleteBackward()
            return
        }
        
        // 2. 判断是不是emojo
        if let emoji = em.emojo,
            let textRange = selectedTextRange {
            
            // 向文本当中插入emoji
            // UITextRange 只用在这一个地方
            replace(textRange, withText: emoji)
            return
        }
        
        // 点击图片才会执行到这里.
        // 所有的排版系统当中, 几乎有一个共同的特点, 插入的字符的显示, 跟随前一个字符的属性, 但是本身没有属性, 就是我们输入同一个表情多次的时候, 由于后面的都没有属性, 所有图片表情显示的会不一样. 所以我们需要给每一个表情设置属性 将属性设置放到方法里面去
        //        let imageText = NSMutableAttributedString(attributedString: em.imageText(font: textView.font!))
        //        imageText.addAttributes([NSAttributedStringKey.font: textView.font!], range: NSRange(location: 0, length: 1))
        
        // 0> 获取我们点击的图片的属性文本
        let imageText = em.imageText(font: font!)
        
        // 1> 将当前textView 的属性文本 变为 可变的
        let attrStrM = NSMutableAttributedString(attributedString: attributedText)
        
        // 2> 将图像的属性文本插入到当前光标位置
        attrStrM.replaceCharacters(in: selectedRange, with: imageText)
        
        // 3> 重新设置属性文本
        // 记录光标位置
        let range = selectedRange
        
        
        attributedText = attrStrM
        
        // 恢复光标位置
        // length 是选中字符的长度, 插入文本后应该为0
        selectedRange = NSRange(location: range.location + 1, length: 0)
        
        
        // 让代理执行代理方法 - 在需要的时候, 通知代理执行协议方法.
        delegate?.textViewDidChange?(self)
        
        textChange()
        
    }
    
    
}

private extension WMComposeTextView {
    
    func setupUI() {
        
        // 0. 注册通知
        // 通知是一对多, 如果其他控件监听当前文本视图的通知, 不会影响
        // 但是如果使用代理, 其他控件就无法使用代理监听到.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChange),
            name: NSNotification.Name.UITextViewTextDidChange,
            object: self)
        
        // 1. 设置占位标签
        placeholderLabel.text = "分享新鲜事..."
        placeholderLabel.font = self.font
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.lightGray
        
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        
        addSubview(placeholderLabel)
        
    }
    
}
