//
//  ZXEmoticonManager.swift
//  表情包数据
//
//  Created by windorz on 2018/3/11.
//  Copyright © 2018年 windorz. All rights reserved.
//

// 创建一个表情管理单例
import Foundation
import YYModel

// 表情管理器 不用继承 NSObject 如果不需要字典转模型的话
class ZXEmoticonManager {
    
    // 为了方便表情的复用, 建立一个单例, 只加载移除表情数据
    // 创建一个表情管理器的单例
    static let shared = ZXEmoticonManager()
    
    // 创建一个表情包的懒加载数组
    lazy var packages = [ZXEmoticonPackage]()
    
    // 新加入一个属性, 就是获取 bundle 的路径
    lazy var bundle: Bundle = {
        
        let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil)
        return Bundle(path: path!)!
        
    }()
    
    // 构造函数, 如果在 Init 之前加上private 修饰符, 可以要求调用者必须通过 shared 访问对象
    // OC 需要重写 allocWithZone 方法
    private init() {
        
        loadPackages()
    }
    
    
    
    /// 添加最近使用的表情
    ///
    /// - Parameter em: 返回一个装有表情的数组
    func recentEmoticon(em: ZXEmoticon) {
        
        // 1. 增加当前表情的使用次数
        em.times += 1
        
        // 2. 判断是否已经记录了该表情, 如果没有记录就添加记录.
        if !packages[0].emoticons.contains(em) {
            
            packages[0].emoticons.append(em)
        }
        
        
        // 3. 根据当前的使用次数排序
//        packages[0].emoticons.sort { (em1, em2) -> Bool in
//            return em1.times > em2.times
//        }
        // 在Swift 当中, 如果一个闭包只有一个return 的话, 参数名可以省略, 参数用$0..进行代替
        packages[0].emoticons.sort { $0.times > $1.times }
        // 4. 判断表情数组是否超出20个, 如果超出就直接移除超出的部分
        if packages[0].emoticons.count > 20 {
            packages[0].emoticons.removeSubrange(20..<packages[0].emoticons.count)
        }
    }
    
}


// MARK: - 表情包符号处理
extension ZXEmoticonManager {
    
    
    
    /// 将给定的字符串转换成属性文本
    ///
    /// 关键点: 要按匹配结果倒叙替换属性文本!
    /// - Parameter string: 完整的字符串
    /// - Returns: 属性文本
    func emticonString(string: String, font: UIFont) -> NSAttributedString {
        
        let attrString = NSMutableAttributedString(string: string)
        
        // 1. 建立正则表达式, 过滤所有的表情文字
        // [] () 都是正则表达式的关键字, 如果要参与匹配则需要转义
        
        let pattern = "\\[.*?\\]"
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            
            return attrString
        }
        
        // 2. 匹配所有项 用一个数组进行接收, 注意是不可选的, 也就是数组一定有值.
        let matches = regx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 3. 遍历所有的匹配结果, 没有() 加持, 所以应该从0开始匹配
        for m in matches.reversed() {
            let range = m.range(at: 0)
            // 获取到两个 range1 {1, 4}, range2 {6, 5}
            // 但是这里不能进行正序替换字符串为表情图片, 因为一旦替换第一个, 后面再进行替换就会全部失效. 所以这里应该倒序

            let subStr = (attrString.string as NSString).substring(with: range)
            
            if let em = ZXEmoticonManager.shared.findEmoticon(string: subStr) {
                
                print(em)
                
                attrString.replaceCharacters(in: range, with: em.imageText(font: font))
            }
        }
        
        // 4. 统一设置一遍字符串的属性 除了需要设置字体外, 还需要设置字体颜色.
        attrString.addAttributes([NSAttributedStringKey.font: font,
                                  NSAttributedStringKey.foregroundColor: UIColor.darkGray], range: NSRange(location: 0, length: attrString.length))
        
        return attrString
        
    }

    
    
    /// 根据 string '[爱你]' 在所有的表情符号中查找对应的表情模型对象
    ///
    /// - Parameter string: 传入一个查找字符串
    /// - Returns: 返回一个模型对象
    func findEmoticon(string: String) -> ZXEmoticon? {
        
        // 1. 遍历表情包
        // OC 当中过滤数组使用 [谓词]
        // Swift 中则更加简单
        
        for p in packages {
            
            // 2. 在表情包模型中的表情数组里面 进行 过滤 string
            // 方法一 尾随闭包的简写
//            let result = p.emoticons.filter({ (em) -> Bool in
//                return em.chs == string
//            })
            
            // 方法二
//            let result = p.emoticons.filter() { (em) -> Bool in
//                return em.chs == string
//            }
            
            // 方法三 - 如果闭包当中只有一句, 并且是返回
            // 1. 闭包格式可以省略
            // 2. 参数省略后, 使用$0 , $1... 依次代替
//            let result = p.emoticons.filter() {
//                    return $0.chs == string
//            }
            
            // 方法四: 如果闭包中只有一句, 并且是返回
            // 1. 闭包格式定义可以省略
            // 2. 参数省略后用 $0, $1 依次代替原有的参数
            // 3. return 也可以省略
            let result = p.emoticons.filter() { $0.chs == string }
            
            if result.count == 1 {
                
                return result[0]
                
            }
        }
        
        
        return nil
    }
    
    
    
}

// MARK: - 表情包数据处理
extension ZXEmoticonManager {
    
    // 从本地加载 bundle
    func loadPackages() {
        
        // 1. 首先获取 bundel 文件在整个项目当中的路径 path 可选进而守护
        // 2. 用我们获取到的路径创建一个 bundle 然后路径查询 发现是我们本地的 bundle 可选进行守护
        // 3. 接下来, 在 bundle 里面进行查询 存放所有数据的 info.plist文件 可选进而守护
        // 注意点: 为什么我们直接拼接了目标 plist文件的名称, 而不带前面的各个文件夹, 因为 bundle 是苹果公司采用的一种格式, 可以查看对应的应用程序的包, 都是 bundle. 如果是 Contents/Resources 这样的路径的话, 我们就可以直接输入目标文件名, 至于路径, 系统会自动补全.
        // 4. 获取 plist 中的数据 观察数据类型, 可选进而守护
        
        // 5. 数组字典转模型 可选进而守护
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
        let bundle = Bundle(path: path),
        let plistPath = bundle.path(forResource: "emoticons", ofType: "plist"),
        let array = NSArray(contentsOfFile: plistPath) as? [[String: String]],
        let models = NSArray.yy_modelArray(with: ZXEmoticonPackage.self, json: array) as? [ZXEmoticonPackage] else {
            
            return
            
        }
        
        // 设置表情包数据
        // 使用 += 不需要再次给 packages 分配空间, 使用一开始懒加载的空间就够了, 直接追加数据
        packages += models
        

    }
    
    
}
