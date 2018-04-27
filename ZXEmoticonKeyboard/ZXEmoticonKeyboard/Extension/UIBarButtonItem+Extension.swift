//
//  UIBarButtonItem+Extension.swift
//  WMWeibo
//
//  Created by 张雄 on 2017/11/21.
//  Copyright © 2017年 张雄. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
	
	// 构造函数
	convenience init(title: String, fontSize: CGFloat = 16, target: Any?, action: Selector, isBack: Bool = false) {
		
		
//		let btn: UIButton = UIButton.cz_textButton(title, fontSize: fontSize, normalColor: UIColor.darkGray, selectedColor: UIColor.orange)
		
		//let btn: UIButton = UIButton.cz_titleButton(title, fontSize: fontSize, normalColor: UIColor.darkGray, highLightColor: UIColor.orange)
        
        let btn = UIButton.init(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.setTitleColor(UIColor.orange, for: .highlighted)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
		btn.sizeToFit()
        
		if isBack {
			// navigationbar_back_withtext
			// navigationbar_back_withtext_highlighted
			let imageName = "navigationbar_back_withtext"
			btn.setImage(UIImage.init(named: imageName), for: .normal)
			btn.setImage(UIImage.init(named: imageName + "_highlighted"), for: .highlighted)
			
			btn.sizeToFit()
			
		}
		
		// OC 构架不够完整 上面创建的按钮, 系统根本不知道它是一个按钮 所以需要指定按钮类型
		// btn?.addTarget(target, action: action, for: .touchUpInside)
		btn.addTarget(target, action: action, for: .touchUpInside)
		
		self.init(customView: btn)
		
		
	}
	
	
	// tips: 构造函数里面构造需要什么, 那么我们就传递进什么参数即可, 最后需要执行父类的方法
	
	
	
}
