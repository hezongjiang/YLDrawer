//
//  MainViewController.swift
//  Drawer
//
//  Created by he on 2017/7/13.
//  Copyright © 2017年 hezongjiang. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    fileprivate lazy var backImage = UIImageView(image: UIImage(named: "mainImage"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.cyan
        
        backImage.frame = view.bounds
        backImage.contentMode = .scaleAspectFill
        backImage.clipsToBounds = true
        view.addSubview(backImage)
        
        title = "标题"
    }

}
