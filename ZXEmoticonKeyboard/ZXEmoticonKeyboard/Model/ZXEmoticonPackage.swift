//
//  ZXEmoticonPackage.swift
//  表情包数据
//
//  Created by windorz on 2018/3/11.
//  Copyright © 2018年 windorz. All rights reserved.
//

import UIKit
import YYModel

// 表情包模型
class ZXEmoticonPackage: NSObject {

    /// 表情包的分组名
    @objc var groupName: String?
    
    @objc var bgImageName: String?
    
    /// 表情包目录
    @objc var directory: String? {
        didSet {
            // 重新设置目录info.plist
            // 1. 获取到 directory 可选进行守护
            // 2. 根据 HMEmoticon.bundle 路径 一共会获取三次路径 可选进行守护
            // 3. 根据路径获取 bundle 可选守护
            // 4. 获取bundle 里面对应info.plist的路径 ok 获取到了所有表情的路径 可选守护
            // 5. 获取每个info.plist 里面的数据 array 可选守护
            // 6. 数组赋值给模型 记得类型转换. 同时需要可选守护
            // 7. 最后一步, 设置表情模型数组
            guard let directory = directory,
            let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path),
            let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
            let array = NSArray(contentsOfFile: infoPath) as? [[String: String]],
            let models = NSArray.yy_modelArray(with: ZXEmoticon.self, json: array) as? [ZXEmoticon] else {
                return
            }
            
            // 遍历 models 数组, 设置每一个模型的 directory.
            for m in models {
                m.directory = directory
            }
            
            
            // 设置表情模型数组
            emoticons += models
    
//            print(models)
            
            
        }
        
    }
    
    // 懒加载的表情模型的空数组
    /// 使用懒加载可以避免后续的解包
    @objc lazy var emoticons = [ZXEmoticon]()
    
    var numberOfPages: Int {
        
        return (emoticons.count - 1) / 20 + 1
    }
    
    // 从懒加载的表情包当中 按照page数 来截取最多20个 表情模型的数组
    // 例如有 26个表情
    // page = 0 返回 第0-19 表情模型数组
    // page = 1 返回 第20-25 表情模型数组
    func emotions(page: Int) -> [ZXEmoticon] {
        
        // 每一页表情的数量
        let count = 20
        let location = 20 * page
        var length = count
        
        // 判断数组是否越界
        if location + length > emoticons.count {
            length = emoticons.count - location
        }
        
        let range = NSRange(location: location, length: length)
        
        // 截取数组的子数组
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        
        return subArray as! [ZXEmoticon]
    }
    
    override var description: String {
        
        return yy_modelDescription()
    }
    
    
}
