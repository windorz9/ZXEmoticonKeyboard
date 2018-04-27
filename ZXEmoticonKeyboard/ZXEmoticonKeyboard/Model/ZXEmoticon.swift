//
//  ZXEmoticon.swift
//  表情包数据
//
//  Created by windorz on 2018/3/11.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit
import YYModel

// 表情模型
class ZXEmoticon: NSObject {

    // 进入表情的分组进行查看, 看我们需要什么数据
    // 表情类型 false - 图片表情 / true - emoji
    @objc var type = false
    
    // 表情字符串 发送给新浪微博服务器, 节约流量
    @objc var chs: String?
    
    // 表情图片名称 用于本地图文混排
    @objc var png: String?
    
    @objc var times: Int = 0
    
    // emoji 的十六进制编码
    @objc var code: String? {
        didSet {
            
            guard let code = code else {
                return
            }
            
            let scanner = Scanner(string: code)
            
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            
        
            emojo = String(Character(UnicodeScalar(result)!))
        
        }
        
    }
    
    
    @objc var emojo: String?
    
    // 新加一个属性, 模型所在的目录
    // 由于 info.plist 里面没有这个属性, 我们只能通过外界表情包模型遍历赋值给表情模型才行
    @objc var directory: String?
    
    // 新加入一个计算型属性, 在里面讲图片获取好
    // '图片' 表情对应的图像
    var imgae: UIImage? {
        
        if type {
            return nil
        } else {
            
            guard let directory = directory,
                let png = png,
                let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path) else {
                return nil
            }
            
            // 需要图片名 和 bundle 和 指定设备横竖屏
            return UIImage(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
            
        }
        
        
    }
    
    // 将当前的图像转换生成图片的属性文本
    func imageText(font: UIFont) -> NSAttributedString {
        
        // 1. 判断图像是否存在
        guard let image = imgae else {
            return NSAttributedString(string: "")
        }
        
        // 2. 创建文本附件
        let attachment = ZXEmoticonTextAttachment()
        attachment.image = image
        attachment.chs = chs
        
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        
        // 返回图片的属性文本
        // 获取可变文本
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        attrStrM.addAttributes([NSAttributedStringKey.font: font], range: NSRange(location: 0, length: 1))
        
        
        return attrStrM
        
    }
    
    override var description: String {
        
        return yy_modelDescription()
    }
    
    
    
}
