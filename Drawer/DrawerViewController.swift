//
//  ViewController.swift
//  Drawer
//
//  Created by he on 2017/7/13.
//  Copyright © 2017年 hezongjiang. All rights reserved.
//

import UIKit

// 菜单状态枚举
enum MenuState {
    
    /// 折叠
    case collapsed
    /// 展开中
    case expanding
    /// 已展开
    case expanded
}

enum CascadingStyles {
    case mainViewInTop
    case letfViewInTop
}

public class DrawerViewController: UIViewController {

    /// 主视图控制器
    fileprivate let mainViewController: UIViewController
    
    /// 左侧视图控制器
    fileprivate let leftViewController: UIViewController
    
    /// 菜单打开后主页在屏幕右侧露出部分的宽度
    public var menuViewExpandedOffset: CGFloat = 100
    
    /// 菜单黑色半透明遮罩层最小透明度(0 ~ 1)
    public var coverMinAlpha: CGFloat = 0.1
    
    /// 背景颜色
    public var backGoundColor: UIColor = .white
    
    /// 背景图片
    public var backGoundImage: UIImage? {
        didSet {
            let imageView = UIImageView(image: backGoundImage)
            imageView.frame = view.bounds
            view.insertSubview(imageView, at: 0)
        }
    }
    
    /// 侧滑开始时，菜单视图起始的偏移量
    fileprivate let menuViewStartOffset: CGFloat = 60
    
    /// 最小缩放比例
    fileprivate let minProportion: CGFloat = 0.8
    
    /// 侧滑菜单黑色半透明遮罩层
    fileprivate lazy var blackCover: UIVisualEffectView = {
        
        let effect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return effect
    }()
    
    /// 主页遮盖
    fileprivate lazy var mainViewCover: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleTapGesture), for: .touchUpInside)
        return button
    }()
    
    /// 菜单页当前状态
    fileprivate var currentState = MenuState.collapsed {
        didSet {
            // 菜单展开的时候，给主页面边缘添加阴影
            let shouldShowShadow = currentState != .collapsed
            showShadowForMainViewController(shouldShowShadow)
        }
    }
    
    public init(mainViewController: UIViewController, leftViewController: UIViewController) {
        
        self.mainViewController = mainViewController
        
        self.leftViewController = leftViewController
        
        super.init(nibName: nil, bundle: nil)
        
        // 添加主视图
        let mainView = mainViewController.view!
        mainView.frame = view.bounds
        view.addSubview(mainView)
        addChildViewController(mainViewController)
        
        // 添加拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        mainView.addGestureRecognizer(pan)
        
        // 添加左侧视图
        let leftView = leftViewController.view!
        view.backgroundColor = leftView.backgroundColor
        leftView.frame = view.bounds
        addChildViewController(leftViewController)
    }
    
    /// 单击手势响应
    @objc fileprivate func handleTapGesture() {
        
        // 如果菜单是展开的点击主页部分则会收起
        if currentState == .expanded {
            
            animateMainView(shouldExpand: false)
        }
    }
    
    /// 拖拽手势
    @objc fileprivate func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        switch(recognizer.state) {
        
        case .began: // 刚刚开始滑动
            // 判断拖动方向
            let dragFromLeftToRight = (recognizer.velocity(in: view).x > 0)
            // 如果刚刚开始滑动的时候还处于主页面，从左向右滑动加入侧面菜单
            if (currentState == .collapsed && dragFromLeftToRight) {
                currentState = .expanding
                addMenuViewController()
            }
        
        case .changed: // 如果是正在滑动，则偏移主视图的坐标实现跟随手指位置移动
            let screenWidth = view.frame.width
            let halfScreenWidth = screenWidth * 0.5
            var centerX = recognizer.view!.center.x + recognizer.translation(in: view).x
            // 页面滑到最左侧的话就不许要继续往左移动
            if centerX < halfScreenWidth { centerX = halfScreenWidth }
            
            // 计算缩放比例
            let percent: CGFloat = (centerX - halfScreenWidth) / (screenWidth - menuViewExpandedOffset)
            let proportion = 1 - (1 - minProportion) * percent
            
            // 执行视差特效
            blackCover.alpha = (proportion - minProportion) / (1 - minProportion) - coverMinAlpha
            recognizer.view!.center.x = centerX
            recognizer.setTranslation(CGPoint.zero, in: view)
            // 缩放主页面
            //            recognizer.view!.transform = CGAffineTransform.identity.scaledBy(x: proportion, y: proportion)
            
            // 菜单视图移动
            leftViewController.view.center.x = halfScreenWidth - menuViewStartOffset * (1 - percent)
            
            // 菜单视图缩放
            let menuProportion = (1 + minProportion) - proportion
            print("百分比\(percent)")
            print("缩放比\(menuProportion)")
            leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: menuProportion, y: menuProportion)
            
        case .ended: // 如果滑动结束
            // 根据页面滑动是否过半，判断后面是自动展开还是收缩
            let hasMovedhanHalfway = recognizer.view!.center.x > view.frame.width
            animateMainView(shouldExpand: hasMovedhanHalfway)
        default:
            break
        }
    }
    
    /// 侧滑开始时，添加菜单页
    fileprivate func addMenuViewController() {
        
        leftViewController.view.center.x = view.frame.width * 0.5 * (1 - (1 - minProportion) * 0.5) - menuViewStartOffset
        
        leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: minProportion, y: minProportion)
        
        // 插入当前视图并置顶
        view.insertSubview(leftViewController.view, belowSubview: mainViewController.view)
        
        // 在侧滑菜单之上增加黑色遮罩层，目的是实现视差特效
        blackCover.frame = view.frame.offsetBy(dx: 0, dy: 0)
        view.insertSubview(blackCover, belowSubview: mainViewController.view)
    }
    
    /// 主页自动展开、收起动画
    ///
    /// - Parameter shouldExpand: 是否展开
    public func animateMainView(shouldExpand: Bool) {
        
        if (shouldExpand) { // 如果是用来展开
            
            // 更新当前状态
            currentState = .expanded
            // 动画
            let mainPosition = view.frame.width * (1 + minProportion * 0.5) - menuViewExpandedOffset * 0.5
            doTheAnimate(mainPosition, mainProportion: minProportion, menuPosition: view.bounds.width * 0.5, menuProportion: 1, blackCoverAlpha: 0, usingSpringWithDamping: 0.6) { finished in
                
                let mianView = self.mainViewController.view!
                self.mainViewCover.frame = mianView.bounds
                mianView.addSubview(self.mainViewCover)
            }
            
        } else { // 如果是用于隐藏
            
            let menuPosition = view.frame.width * 0.5 * (1 - (1 - minProportion) * 0.5) - menuViewStartOffset
            // 动画
            doTheAnimate(view.frame.width * 0.5, mainProportion: 1, menuPosition: menuPosition, menuProportion: minProportion, blackCoverAlpha: 1 - coverMinAlpha, usingSpringWithDamping: 1) { finished in
                
                // 动画结束之后更新状态
                self.currentState = .collapsed
                // 移除左侧视图
                self.leftViewController.view.removeFromSuperview()
                // 移除黑色遮罩层
                self.blackCover.removeFromSuperview()
                // 移除主视图透明遮罩
                self.mainViewCover.removeFromSuperview()
            }
        }
    }
    
    /// 主页移动动画、黑色遮罩层动画、菜单页移动动画
    fileprivate func doTheAnimate(_ mainPosition: CGFloat, mainProportion: CGFloat, menuPosition: CGFloat, menuProportion: CGFloat, blackCoverAlpha: CGFloat, usingSpringWithDamping: CGFloat, completion: ((Bool) -> Void)? = nil) {
        
        // usingSpringWithDamping：1.0表示没有弹簧震动动画
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            
            self.mainViewController.view.center.x = mainPosition
            self.blackCover.alpha = blackCoverAlpha
            
            // 缩放主页面
            //                    self.mainNavigationController.view.transform = CGAffineTransform.identity.scaledBy(x: mainProportion, y: mainProportion)
            
            // 菜单页移动
            self.leftViewController.view.center.x = menuPosition

            // 菜单页缩放
            self.leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: menuProportion, y: menuProportion)
            
        }, completion: completion)
        
    }
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    /// 给主页面边缘添加、取消阴影
    fileprivate func showShadowForMainViewController(_ shouldShowShadow: Bool) {
        
        if (shouldShowShadow) {
            mainViewController.view.layer.shadowOpacity = 1
            
        } else {
            mainViewController.view.layer.shadowOpacity = 0
        }
    }
    
}
