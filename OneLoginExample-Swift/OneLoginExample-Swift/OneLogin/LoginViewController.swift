//
//  SwiftNewLoginViewController.swift
//  OneLoginExample
//
//  Created by 刘练 on 2020/2/4.
//  Copyright © 2020 geetest. All rights reserved.
//

import UIKit
import OneLoginSDK
import MediaPlayer

struct ValidateTokenResult: Codable {
    var status: Int
    var result: String?
}

class LoginViewController: BaseViewController {

    @IBOutlet weak var normalLoginButton: UIButton!
    @IBOutlet weak var popupLoginButton: UIButton!
    @IBOutlet weak var floatWindowLoginButton: UIButton!
    @IBOutlet weak var landscapeLoginButton: UIButton!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
        
    // MARK: deinit
    
    deinit {
        self.player?.pause()
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "一键登录"
        
        self.initOneLogin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.normalLoginButton.isEnabled = true
        self.popupLoginButton.isEnabled = true
        self.floatWindowLoginButton.isEnabled = true
        self.landscapeLoginButton.isEnabled = true
    }
    
    // MARK: Init OneLogin
    
    func initOneLogin() {
        // 设置日志开关，建议平常调试过程中打开，便于排查问题，上线时可以关掉日志
        OneLoginPro.setLogEnabled(true)
        // 设置AppId，AppID通过后台注册获得，从极验后台获取该AppID，AppID需与bundleID配套
        OneLoginPro.register(withAppID: GTOneLoginAppId)
    }
    
    // MARK: Button Actions
    
    @IBAction func normalLoginAction(_ sender: UIButton) {
        // 防抖，避免重复点击
        sender.isEnabled = false
        
        // 若不需要自定义UI，可不设置任何参数，使用SDK默认配置即可
        let viewModel = OLAuthViewModel()
        
        // -------------- 自定义UI设置 -----------------
        if NeedCustomAuthUI {
            // --------------状态栏设置 -------------------
            viewModel.statusBarStyle = .lightContent
            
            // -------------- 授权页面背景图片设置 -------------------
            viewModel.backgroundColor = .white
            
            // -------------- 导航栏设置 -------------------
            viewModel.naviTitle = NSAttributedString.init(string: "一键登录", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]) // 导航栏标题
            viewModel.naviBgColor = .clear // 导航栏背景色
//            viewModel.naviBackImage = UIImage.init(named: "back") // 导航栏返回按钮
            viewModel.backButtonHidden = false // 是否隐藏返回按钮，默认不隐藏
            let backButtonRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0)) // 返回按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
            viewModel.backButtonRect = backButtonRect
            if !OLAuthVCAutoLayout {
                // 导航栏右侧控制视图
                let rightBarButton = UIButton.init(type: UIButton.ButtonType.custom)
                rightBarButton.setTitle("完成", for: UIControl.State.normal)
                rightBarButton.addTarget(self, action: #selector(doneAction), for: UIControl.Event.touchUpInside)
                viewModel.naviRightControl = rightBarButton
            }
            
            // -------------- logo设置 -------------------
            viewModel.appLogo = UIImage.init(named: "网关取号_logo")
            let logoRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 20, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0)) // logo偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置，logo大小默认为图片大小
            viewModel.logoRect = logoRect
            viewModel.logoHidden = false // 是否隐藏logo，默认不隐藏
            viewModel.logoCornerRadius = 0
            
            // -------------- 手机号设置 -------------------
            viewModel.phoneNumColor = UIColor.red // 颜色
            viewModel.phoneNumFont = UIFont.boldSystemFont(ofSize: 25) // 字体
            let phoneNumRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0)) // 手机号偏移设置
            viewModel.phoneNumRect = phoneNumRect
            
            // -------------- 切换账号设置 -------------------
            viewModel.switchButtonColor = UIColor.brown // 切换按钮颜色
            viewModel.switchButtonFont = UIFont.systemFont(ofSize: 15)  // 切换按钮字体
            viewModel.switchButtonText = "自定义切换按钮文案"  // 切换按钮文案
            viewModel.switchButtonHidden = false // 是否隐藏切换按钮，默认不隐藏
            let switchButtonRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0))  // 切换按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
            viewModel.switchButtonRect = switchButtonRect
            
            // -------------- 授权登录按钮设置 -------------------
            viewModel.authButtonImages = [(UIImage.init(named: "bg_logo_launch") ?? UIImage.init()), (UIImage.init(named: "bg_logo_launch") ?? UIImage.init()), (UIImage.init(named: "bg_logo_launch") ?? UIImage.init())] // 授权按钮背景图片
            viewModel.authButtonTitle = NSAttributedString.init(string: "授权登录", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]) // 登录按钮文案
            let authButtonRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 300, height: 40)) // 授权按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
            viewModel.authButtonRect = authButtonRect
            viewModel.authButtonCornerRadius = 0 // 授权按钮圆角，默认为0
            viewModel.clickAuthButtonBlock = { // 点击授权页面登录按钮回调
                print("clickAuthButtonBlock")
            }
            
            // -------------- slogan设置 -------------------
            viewModel.sloganTextColor = UIColor.cyan // slogan颜色
            viewModel.sloganTextFont = UIFont.systemFont(ofSize: 14) // slogan字体
            let sloganRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0))  // slogan偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
            viewModel.sloganRect = sloganRect
            
            // -------------- 服务条款设置 -------------------
            viewModel.defaultCheckBoxState = true
            let checkBoxRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 12, height: 12)) // 复选框尺寸，默认为12*12
            viewModel.checkBoxRect = checkBoxRect
            
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.lineSpacing = 1.33
            paragraphStyle.alignment = NSTextAlignment.left
            paragraphStyle.paragraphSpacing = 0.0
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.firstLineHeadIndent = 0.0
            viewModel.privacyTermsAttributes = [NSAttributedString.Key.foregroundColor : UIColor.orange, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle : paragraphStyle]
            
            let item1 = OLPrivacyTermItem.init(title: "自定义服务条款1", linkURL: URL.init(string: "https://docs.geetest.com/onelogin/overview/start")!, index: 0) { (termItem: OLPrivacyTermItem, controller: UIViewController) in
                print("termItem.termLink: \(termItem.termLink), controller: \(controller)")
            }
            let item2 = OLPrivacyTermItem.init(title: "自定义服务条款2", linkURL: URL.init(string: "https://docs.geetest.com/")!, index: 0)
            viewModel.additionalPrivacyTerms = [item1, item2]
            let termsRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: 0, height: 0))  // 服务条款偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
            viewModel.termsRect = termsRect
            viewModel.auxiliaryPrivacyWords = ["条款前文案", "&", "&", "条款后的文案"]   // 条款之外的文案，默认可不设置
            
            viewModel.clickCheckboxBlock = { (isChecked) in      // 点击隐私条款前勾选框回调
                print("clickCheckboxBlock isChecked: \(isChecked ? "true" : "false")")
            }
            
            viewModel.termsAlignment = NSTextAlignment.center
            
            // -------------- 服务条款H5页面导航栏设置 -------------------
            viewModel.webNaviBgColor = UIColor.purple // 服务条款导航栏背景色
            viewModel.webNaviHidden = false
            
            // -------------- 授权页面支持的横竖屏设置 -------------------
            viewModel.supportedInterfaceOrientations = UIInterfaceOrientationMask.allButUpsideDown
            
            // -------------- 自定义UI设置，如，可以在授权页面添加三方登录入口 -------------------
            let customBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 40))
            customBtn.setTitle("我是自定义UI", for: UIControl.State.normal)
            customBtn.backgroundColor = UIColor.red
            customBtn.layer.cornerRadius = 2.0
            customBtn.addTarget(self, action: #selector(dismissAuthVC), for: UIControl.Event.touchUpInside)
            
            var customAreaWidth = 0.0
            var customAreaHeight = 0.0
            
            viewModel.customUIHandler = { (customAreaView: UIView) in
                customAreaView.addSubview(customBtn)
                customBtn.center = CGPoint.init(x: customAreaView.bounds.size.width/2, y: customAreaView.bounds.size.height/2 + 150)
                customAreaWidth = Double(customAreaView.bounds.size.width > customAreaView.bounds.size.height ? customAreaView.bounds.size.height : customAreaView.bounds.size.width)
                customAreaHeight = Double(customAreaView.bounds.size.width < customAreaView.bounds.size.height ? customAreaView.bounds.size.height : customAreaView.bounds.size.width)
            }
            
            // -------------- 授权页面自动旋转时的回调，在该回调中调整自定义视图的frame，若授权页面不支持自动旋转，或者没有添加自定义视图，可不用实现该block -------------------
            viewModel.authVCTransitionBlock = { (size, coordinator, customAreaView) in
                // 背景视图横竖屏旋转适配
                if let playerLayer = self.playerLayer {
                    playerLayer.frame = CGRect.init(x: playerLayer.frame.origin.x, y: playerLayer.frame.origin.y, width: size.width, height: size.height)
                }
                
                if size.width > size.height { // 横屏
                    customBtn.center = CGPoint.init(x: customAreaHeight/2, y: customAreaWidth/2 - 15)
                } else {                      // 竖屏
                    customBtn.center = CGPoint.init(x: customAreaHeight/2, y: customAreaWidth/2 + 150)
                }
            }
            
            // -------------- 授权页面点击登录按钮之后的loading设置 -------------------
            viewModel.loadingViewBlock = { (containerView: UIView) in
                if OneLogin.isProtocolCheckboxChecked() {
                    let indicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
                    containerView.addSubview(indicatorView)
                    indicatorView.center = CGPoint.init(x: containerView.bounds.size.width/2, y: containerView.bounds.size.height/2)
                    indicatorView.startAnimating()
                }
            }
            
            viewModel.stopLoadingViewBlock = { (containerView: UIView) in
                for subview in containerView.subviews {
                    if subview is UIActivityIndicatorView {
                        (subview as! UIActivityIndicatorView).stopAnimating()
                        subview.removeFromSuperview()
                        break
                    }
                }
            }
            
            // -------------- 授权页面未勾选服务条款时点击登录按钮的提示 -------------------
            viewModel.notCheckProtocolHint = "请您先同意服务条款"  // 授权页面未勾选服务条款时点击登录按钮的提示，默认为"请同意服务条款"
            
            // -------------- 进入授权页面的方式 -------------------
            viewModel.pullAuthVCStyle = OLPullAuthVCStyle.push // 默认为 modal
            
            // -------------- 授权弹窗设置 -------------------
            // 是否显示授权弹窗，不显示的话在未授权时会弹出请同意服务条款提示
            viewModel.willAuthDialogDisplay = true
            // 弹窗是否显示在底部，为 NO 时弹窗会在屏幕中间显示
            viewModel.isAuthDialogBottom = true
            // 弹窗尺寸、圆角大小及位置
            viewModel.authDialogRect = OLRect(portraitTopYOffset: 0, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: UIScreen.main.bounds.size.width, height: 34))
            viewModel.authDialogCornerRadius = 8
            viewModel.authDialogRectCorners = [NSNumber.init(value: UIRectCorner.topLeft.rawValue), NSNumber.init(value: UIRectCorner.topRight.rawValue)]
            
            // 弹窗动画
            viewModel.authDialogAnimationStyle = .coverVertical
            
            // 弹窗标题、内容设置
            viewModel.authDialogTitleFont = UIFont.systemFont(ofSize: 20)
            viewModel.authDialogTitleText = "请同意下述服务条款"
            viewModel.authDialogTitleColor = UIColor.black
            viewModel.authDialogContentFont = UIFont.systemFont(ofSize: 14)
            
            // 同意按钮设置
            viewModel.authDialogAgreeBtnFont = UIFont.systemFont(ofSize: 16)
            viewModel.authDialogAgreeBtnText = "同意并继续"
            viewModel.authDialogAgreeBtnColor = UIColor.white
            
            // 不同意按钮设置
            viewModel.authDialogAgreeBtnFont = UIFont.systemFont(ofSize: 16)
            viewModel.authDialogAgreeBtnText = "不同意并返回"
            viewModel.authDialogAgreeBtnColor = UIColor.black
            
            // 是否可以点击弹窗外区域关闭弹窗，默认为 true
            viewModel.canCloseAuthDialogFromTapGesture = false;
            viewModel.tapAuthDialogBackgroundBlock = {
                print("tapAuthDialogBackgroundBlock")
            }
            // 点击不同意按钮关闭弹窗的回调
            viewModel.clickAuthDialogDisagreeBtnBlock = {
                print("clickAuthDialogDisagreeBtnBlock")
            }
            
            // -------------- Autolayout -------------------
            if OLAuthVCAutoLayout {
                viewModel.autolayoutBlock = { [weak self] (authView: UIView, authContentView: UIView, authBackgroundImageView: UIView, authNavigationView: UIView, authNavigationContainerView: UIView, authBackButton: UIView, authNavigationTitleView: UIView, authLogoView: UIView, authPhoneView: UIView, authSwitchButton: UIView, authLoginButton: UIView, authSloganView: UIView, authAgreementView: UIView, authCheckbox: UIView, authProtocolView: UIView, authClosePopupButton: UIView) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    // content
                    authContentView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.edges.equalTo()(authView)
                    }
                    
                    // background
                    authBackgroundImageView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.edges.equalTo()(authContentView)
                    }
                    
                    // navigation
                    authNavigationView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.top().right().equalTo()(authContentView)
                        make?.height.mas_equalTo()(64 + (strongSelf.isIPhoneXScreen() ? 34 : 0))
                    }
                    
                    authNavigationContainerView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.edges.equalTo()(authNavigationView)
                    }

                    authBackButton.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.equalTo()(authNavigationContainerView)?.offset()(20)
                        make?.centerY.equalTo()(authNavigationContainerView)?.offset()(strongSelf.isIPhoneXScreen() ? 20 : 10)
                        make?.size.mas_equalTo()(CGSize.init(width: 20, height: 20))
                    }

                    authNavigationTitleView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authNavigationContainerView)
                        make?.centerY.equalTo()(authNavigationContainerView)?.offset()(strongSelf.isIPhoneXScreen() ? 20 : 10)
                        make?.size.mas_equalTo()(CGSize.init(width: 100, height: 40))
                    }

                    // 导航栏右侧控制视图
                    let rightBarButton = UIButton.init(type: UIButton.ButtonType.custom)
                    rightBarButton.setTitle("完成", for: UIControl.State.normal)
                    rightBarButton.addTarget(strongSelf, action: #selector(strongSelf.doneAction), for: UIControl.Event.touchUpInside)
                    authNavigationContainerView.addSubview(rightBarButton)
                    rightBarButton.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.right.equalTo()(authNavigationContainerView)?.offset()(-10)
                        make?.centerY.equalTo()(authNavigationContainerView)?.offset()(strongSelf.isIPhoneXScreen() ? 20 : 10)
                        make?.size.mas_equalTo()(CGSize.init(width: 60, height: 40))
                    }

                    // logo
                    authLogoView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authContentView)
                        make?.top.equalTo()(authNavigationView.mas_bottom)?.offset()(100)
                        make?.size.mas_equalTo()(CGSize.init(width: 80, height: 80))
                    }

                    // phone
                    authPhoneView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authContentView)
                        make?.top.equalTo()(authLogoView.mas_bottom)?.offset()(20)
                        make?.size.mas_equalTo()(CGSize.init(width: 200, height: 40))
                    }

                    // switchbutton
                    authSwitchButton.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authContentView)
                        make?.top.equalTo()(authPhoneView.mas_bottom)?.offset()(20)
                        make?.size.mas_equalTo()(CGSize.init(width: 200, height: 20))
                    }

                    // loginbutton
                    authLoginButton.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authContentView)
                        make?.top.equalTo()(authSwitchButton.mas_bottom)?.offset()(30)
                        make?.size.mas_equalTo()(CGSize.init(width: 260, height: 40))
                    }

                    // slogan
                    authSloganView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.centerX.equalTo()(authContentView)
                        make?.top.equalTo()(authLoginButton.mas_bottom)?.offset()(20)
                        make?.size.mas_equalTo()(CGSize.init(width: 260, height: 20))
                    }

                    // agreementview
                    authAgreementView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.equalTo()(authContentView)?.offset()(20)
                        make?.right.equalTo()(authContentView)?.offset()(-20)
                        make?.top.equalTo()(authSloganView.mas_bottom)?.offset()(50)
                        make?.height.mas_equalTo()(80)
                    }

                    authCheckbox.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.equalTo()(authAgreementView)?.offset()(10)
                        make?.top.equalTo()(authAgreementView)?.offset()(10)
                    }

                    authProtocolView.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.equalTo()(authCheckbox.mas_right)?.offset()(5)
                        make?.right.equalTo()(authAgreementView)?.offset()(-10)
                        make?.height.equalTo()(authAgreementView)
                        make?.top.equalTo()(authAgreementView)
                    }

                    // 自定义视图
                    let customBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 40))
                    customBtn.setTitle("我是自定义UI", for: UIControl.State.normal)
                    customBtn.backgroundColor = UIColor.red
                    customBtn.layer.cornerRadius = 2.0
                    customBtn.addTarget(strongSelf, action: #selector(strongSelf.dismissAuthVC), for: UIControl.Event.touchUpInside)
                    authContentView.addSubview(customBtn)
                    customBtn.mas_makeConstraints { (make: MASConstraintMaker?) in
                        make?.left.equalTo()(authContentView)?.offset()(20)
                        make?.right.equalTo()(authContentView)?.offset()(-20)
                        make?.height.mas_equalTo()(40)
                        make?.top.equalTo()(authAgreementView.mas_bottom)?.offset()(30)
                    }
                    
                    // 插入自定义背景
                    if let strongSelf = self, let path = Bundle.main.path(forResource: "auth_vc_bg", ofType: "mp4") {
                        let url = URL.init(fileURLWithPath: path)
                        let playerItem = AVPlayerItem.init(url: url)
                        strongSelf.player = AVPlayer.init(playerItem: playerItem)
                        if let player = strongSelf.player {
                            strongSelf.playerLayer = AVPlayerLayer.init(player: player)
                            if let playerLayer = strongSelf.playerLayer {
                                playerLayer.videoGravity = .resize
                                                                
                                let playerView = UIView.init()
                                playerView.frame = UIScreen.main.bounds
                                playerView.backgroundColor = .white
                                playerView.alpha = 0.5
                                authContentView.addSubview(playerView)
                                authContentView.sendSubviewToBack(playerView)
                                playerView.mas_makeConstraints { (make) in
                                    make?.edges.equalTo()(authContentView)
                                }
                                
                                playerView.layer.addSublayer(playerLayer)
                                playerLayer.frame = playerView.bounds
                                
                                player.play()
                                
                                NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.didReceiveAVPlayerItemDidPlayToEndTimeNotification(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                                NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.didReceiveBecomeActiveNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
                            }
                        }
                    }
                }
            }
        }
                
        // --------------授权页面生命周期回调 -------------------
        viewModel.viewLifeCycleBlock = { (viewLifeCycle : String, animated : Bool) in
            print("viewLifeCycle: \(viewLifeCycle), animated: \(animated ? "true" : "false")")
            if viewLifeCycle == "viewDidDisappear:" {
                sender.isEnabled = true
            } else if viewLifeCycle == "viewDidLoad" {
                // 授权页面出现时，关掉进度条
                GTProgressHUD.hideAllHUD()
            }
        }
        
        // 进入授权页面
        
        if !OneLoginPro.isPreGetTokenResultValidate() {
            GTProgressHUD.showLoadingHUD(withMessage: nil)
        }
        
        OneLoginPro.requestToken(with: self, viewModel: viewModel) { [weak self] result in
            if let strongSelf = self {
                strongSelf.finishRequsetingToken(result: result!)
            }
            sender.isEnabled = true
        }
    }
    
    @IBAction func popupLoginAction(_ sender: UIButton) {
        // 防抖，避免重复点击
        sender.isEnabled = false
        
        let viewModel = OLAuthViewModel()
        // 设置为弹窗模式
        viewModel.isPopup = true
        // 隐藏切换账号按钮
        viewModel.switchButtonHidden = true
        // 点击弹窗之外的空白处关闭弹窗
        viewModel.canClosePopupFromTapGesture = true
        
        viewModel.tapAuthBackgroundBlock = {
            print("tapAuthBackgroundBlock")
        }
        
        viewModel.supportedInterfaceOrientations = UIInterfaceOrientationMask.allButUpsideDown
        
        // --------------授权页面生命周期回调 -------------------
        viewModel.viewLifeCycleBlock = { (viewLifeCycle : String, animated : Bool) in
            print("viewLifeCycle: \(viewLifeCycle), animated: \(animated ? "true" : "false")")
            if viewLifeCycle == "viewDidDisappear:" {
                sender.isEnabled = true
            } else if viewLifeCycle == "viewDidLoad" {
                // 授权页面出现时，关掉进度条
                GTProgressHUD.hideAllHUD()
            }
        }
        
        // 进入授权页面
        
        if !OneLoginPro.isPreGetTokenResultValidate() {
            GTProgressHUD.showLoadingHUD(withMessage: nil)
        }
        
        // 弹窗模式，请传 navigationController
        OneLoginPro.requestToken(with: self.navigationController!, viewModel: viewModel) { [weak self] result in
            if let strongSelf = self {
                strongSelf.finishRequsetingToken(result: result!)
            }
            sender.isEnabled = true
        }
    }
    
    @IBAction func floatWindowLogin(_ sender: UIButton) {
        // 防抖，避免重复点击
        sender.isEnabled = false
        
        let viewModel = OLAuthViewModel()
        // 设置为弹窗模式
        viewModel.isPopup = true
        // 隐藏切换账号按钮
        viewModel.switchButtonHidden = true
        // 点击弹窗之外的空白处关闭弹窗
        viewModel.canClosePopupFromTapGesture = true
        
        viewModel.tapAuthBackgroundBlock = {
            print("tapAuthBackgroundBlock")
        }
        
        viewModel.supportedInterfaceOrientations = UIInterfaceOrientationMask.allButUpsideDown
        
        // -------------- 弹窗设置 -------------------
        viewModel.popupAnimationStyle = OLAuthPopupAnimationStyle.coverVertical
        
        let animation = CATransition.init()
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.init(rawValue: "rippleEffect")
        animation.subtype = CATransitionSubtype.fromLeft
        viewModel.popupTransitionAnimation = animation
        
        let popupRect = OLRect(portraitTopYOffset: self.ol_screenHeight() - 340, portraitCenterXOffset: 0, portraitLeftXOffset: 0, landscapeTopYOffset: 0, landscapeCenterXOffset: 0, landscapeLeftXOffset: 0, size: CGSize(width: self.ol_screenWidth(), height: 340))
        viewModel.popupRect = popupRect
        viewModel.popupCornerRadius = 5
        viewModel.closePopupTopOffset = NSNumber.init(value: 3)  // 关闭按钮距弹窗顶部偏移
        viewModel.closePopupRightOffset = NSNumber.init(value: -8)
        viewModel.popupRectCorners = [NSNumber.init(value: UIRectCorner.topLeft.rawValue), NSNumber.init(value: UIRectCorner.topRight.rawValue)]
        
        // --------------授权页面生命周期回调 -------------------
        viewModel.viewLifeCycleBlock = { (viewLifeCycle : String, animated : Bool) in
            print("viewLifeCycle: \(viewLifeCycle), animated: \(animated ? "true" : "false")")
            if viewLifeCycle == "viewDidDisappear:" {
                sender.isEnabled = true
            } else if viewLifeCycle == "viewDidLoad" {
                // 授权页面出现时，关掉进度条
                GTProgressHUD.hideAllHUD()
            }
        }
        
        // 进入授权页面
        
        if !OneLoginPro.isPreGetTokenResultValidate() {
            GTProgressHUD.showLoadingHUD(withMessage: nil)
        }
        
        // 弹窗模式，请传 navigationController
        OneLoginPro.requestToken(with: self.navigationController!, viewModel: viewModel) { [weak self] result in
            if let strongSelf = self {
                strongSelf.finishRequsetingToken(result: result!)
            }
            sender.isEnabled = true
        }
    }
    
    @IBAction func landscapeLogin(_ sender: UIButton) {
        // 防抖，避免重复点击
        sender.isEnabled = false
        
        let viewModel = OLAuthViewModel()
        viewModel.supportedInterfaceOrientations = UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.landscapeLeft.rawValue | UIInterfaceOrientationMask.landscapeRight.rawValue)
        
        // --------------授权页面生命周期回调 -------------------
        viewModel.viewLifeCycleBlock = { (viewLifeCycle : String, animated : Bool) in
            print("viewLifeCycle: \(viewLifeCycle), animated: \(animated ? "true" : "false")")
            if viewLifeCycle == "viewDidDisappear:" {
                sender.isEnabled = true
            } else if viewLifeCycle == "viewDidLoad" {
                // 授权页面出现时，关掉进度条
                GTProgressHUD.hideAllHUD()
            }
        }
        
        // 进入授权页面
        
        if !OneLoginPro.isPreGetTokenResultValidate() {
            GTProgressHUD.showLoadingHUD(withMessage: nil)
        }
        
        // 当用户传入的 viewController 的 navigationController 不为 nil 时，屏幕旋转方向由用户的 UINavigationController 来控制，故此处 controller 需传入 navigationController，否则无法控制屏幕旋转方向
        OneLoginPro.requestToken(with: self.navigationController!, viewModel: viewModel) { [weak self] result in
            if let strongSelf = self {
                strongSelf.finishRequsetingToken(result: result!)
            }
            sender.isEnabled = true
        }
    }
    
    @objc func doneAction(_ sender: UIButton) {
        OneLoginPro.dismissAuthViewController {
            
        }
    }
    
    @objc func dismissAuthVC(_ sender: UIButton) {
        OneLoginPro.dismissAuthViewController {
            
        }
    }
    
    // MARK: AVPlayer
    
    @objc func didReceiveAVPlayerItemDidPlayToEndTimeNotification(_ noti: Notification) {
        if let player = self.player {
            let time = CMTime.init(value: 0, timescale: 1)
            player.seek(to: time)
            player.play()
        }
    }
    
    @objc func didReceiveBecomeActiveNotification(_ noti: Notification) {
        if let player = self.player {
            player.play()
        }
    }
    
    // MARK: Validate Token
    
    func finishRequsetingToken(result: Dictionary<AnyHashable, Any>?) {
        if let result = result, let status = result[OLStatusKey], 200 == (status as! NSNumber).intValue {
            let token = result[OLTokenKey] as! String
            let appID = result[OLAppIDKey] as! String
            let processID = result[OLProcessIDKey] as! String
            var authcode: String? = nil
            if nil != result[OLAuthcodeKey] {
                authcode = result[OLAuthcodeKey] as? String
            }
            self.validateToken(token: token, appId: appID, processID: processID, authcode: authcode) { validateTokenResult in
                DispatchQueue.main.async {
                    var successed = false
                    switch validateTokenResult {
                    case .success(let validateTokenResult):
                        if 200 == validateTokenResult.status, let phone = validateTokenResult.result {
                            successed = true
                            GTProgressHUD.showToast(withMessage: String.init(format: "手机号为：%@", phone))
                            OneLoginPro.renewPreGetToken()
                        } else {
                            if let message = validateTokenResult.result {
                                print("validate token error: \(message)")
                            } else {
                                print("validate token failed")
                            }
                        }
                        
                    case .failure(let error):
                        print("validate token error: \(error)")
                    }
                    
                    if !successed {
                        GTProgressHUD.showToast(withMessage: "登录失败")
                    }
                    
                    OneLoginPro.dismissAuthViewController {
                        
                    }
                }
            }
        } else {
            GTProgressHUD.showToast(withMessage: "登录失败")
            OneLoginPro.dismissAuthViewController {
                
            }
        }
    }
            
    func validateToken(token: String?, appId: String?, processID: String?, authcode: String?, completion: @escaping (Result<ValidateTokenResult, Error>) -> Void) {
        var params = Dictionary<String, Any>.init()
        if let token = token {
            params["token"] = token
        }
        if let processID = processID {
            params["process_id"] = processID
        }
        if let appId = appId {
            params["id_2_sign"] = appId
        }
        if let authcode = authcode {
            params["authcode"] = authcode
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed)
            /**
             * 根据用户自己接口构造
             * demo仅做演示
             * 请不要在线上使用该接口 http://onepass.geetest.com/onelogin/result
             */
            let url = URL.init(string: GTOneLoginResultURL)
            var mRequest = URLRequest.init(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
            mRequest.httpMethod = "POST"
            mRequest.httpBody = data
            let dataTask = URLSession.shared.dataTask(with: mRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                var validateTokenResult: ValidateTokenResult?
                if let data = data {
                    do {
                        validateTokenResult = try JSONDecoder().decode(ValidateTokenResult.self, from: data)
                    } catch {
                        
                    }
                }
                
                if let validateTokenResult = validateTokenResult {
                    completion(.success(validateTokenResult))
                } else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError.init(domain: "validate token error", code: 30000, userInfo: nil)))
                    }
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure(NSError.init(domain: "JSON Serialization error", code: 30001, userInfo: nil)))
        }
    }
}

