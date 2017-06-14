//
//  AACarousel.swift
//  AACarousel
//
//  Created by Alan on 2017/6/11.
//  Copyright © 2017年 Alan. All rights reserved.
//

import UIKit

@objc protocol AACarouselDelegate {
   @objc optional func didSelectCarouselView(_ view:AACarousel, _ currInex:Int)
   @objc optional func callBackFirstDisplayView(_ imageView:UIImageView, _ imageUrl:[String], _ currInex:Int)
   func downloadImages(_ url:String, _ index:Int)
}

let needDownload = "http"

class AACarousel: UIView,UIScrollViewDelegate {
    
    var delegate:AACarouselDelegate?
    var images = [UIImage]()
    enum direction: Int {
        case left = -1, none, right
    }
    
    //MARK:- private property
    private var scrollView:UIScrollView!
    private var describeLabel:UILabel!
    private var layerView:UIView!
    private var pageControl:UIPageControl!
    private var beforeImageView:UIImageView!
    private var currentImageView:UIImageView!
    private var afterImageView:UIImageView!
    private var currentIndex:NSInteger!
    private var describeString = [String]()
    private var timer:Timer?
    private var defaultImg:String?
    private var timerInterval:Double?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithScrollView()
        initWithImageView()
        initWithLayerView()
        initWithLabel()
        initWithPageControl()
        initWithGestureRecognizer()
        setNeedsDisplay()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setScrollViewFrame()
        setImageViewFrame()
        setLayerViewFrame()
        setLabelFrame()
        setPageControlFrame()
        
    }
    
    //MARK:- Interface Builder(Xib,StoryBoard)
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initWithScrollView()
        initWithImageView()
        initWithLayerView()
        initWithLabel()
        initWithPageControl()
        initWithGestureRecognizer()
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- initialize method
    fileprivate func initWithScrollView() {
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        addSubview(scrollView)
        
    }
    
    fileprivate func initWithLayerView() {
        
        layerView = UIView()
        addSubview(layerView)
    }
    
    
    fileprivate func initWithLabel() {
        
        describeLabel = UILabel()
        layerView.addSubview(describeLabel)
    }
    
    fileprivate func initWithPageControl() {
        
        pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        addSubview(pageControl)
    }
    
    fileprivate func initWithImageView() {
        
        beforeImageView = UIImageView()
        currentImageView = UIImageView()
        afterImageView = UIImageView()
        beforeImageView.contentMode = UIViewContentMode.scaleToFill
        currentImageView.contentMode = UIViewContentMode.scaleToFill
        afterImageView.contentMode = UIViewContentMode.scaleToFill
        beforeImageView.clipsToBounds = true
        currentImageView.clipsToBounds = true
        afterImageView.clipsToBounds = true
        scrollView.addSubview(beforeImageView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(afterImageView)
        
    }
    
    fileprivate func initWithGestureRecognizer() {
        
        let singleFinger = UITapGestureRecognizer(target:self, action:#selector(didSelectImageView))
        addGestureRecognizer(singleFinger)
    }
    
    fileprivate func initWithData(_ paths:[String],_ describeTitle:[String]) {
        
        currentIndex = 0
        images.removeAll()
        images.reserveCapacity(paths.count)
     
        //default image
        for _ in 0..<paths.count {
            images.append(UIImage(named: defaultImg ?? "") ?? UIImage())
        }
        
        //get all image
        for i in 0..<paths.count {
            if paths[i].contains(needDownload) {
                downloadImages(paths[i], i)
            } else {
                images[i] = UIImage(named: paths[i]) ?? UIImage()
            }
        }
        
        //get all describeString
        describeString = describeTitle
    }
    
    
    //MARK:- frame method
    fileprivate func setScrollViewFrame() {
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scrollView.contentSize = CGSize.init(width: self.frame.size.width * 5, height:0)
        scrollView.contentOffset = CGPoint.init(x: self.frame.size.width * 2, y: 0)
        
    }
    
    fileprivate func setLayerViewFrame() {
        
        layerView.frame = CGRect.init(x:0 , y: scrollView.frame.size.height - 80, width: scrollView.frame.size.width, height: 80)
        layerView.backgroundColor = UIColor.black
        layerView.alpha = 0.7
        layerView.isUserInteractionEnabled = false
    }
    
    fileprivate func setImageViewFrame() {
        
        beforeImageView.frame = CGRect.init(x:scrollView.frame.size.width , y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        currentImageView.frame = CGRect.init(x:scrollView.frame.size.width * 2 , y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        afterImageView.frame = CGRect.init(x:scrollView.frame.size.width * 3 , y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
    }
    
    fileprivate func setLabelFrame() {
        
        describeLabel.frame = CGRect.init(x:10 , y: layerView.frame.size.height - 75, width: scrollView.frame.size.width - 20, height: 70)
        describeLabel.textAlignment = NSTextAlignment.left
        describeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        describeLabel.numberOfLines = 2
        describeLabel.textColor = UIColor.white
    }
    
    
    fileprivate func setPageControlFrame() {
        
        pageControl.frame = CGRect.init(x:50 , y: scrollView.frame.size.height - 5, width: scrollView.frame.size.width - 100, height: 5)
        pageControl.center = CGPoint.init(x: scrollView.frame.size.width / 2, y: scrollView.frame.size.height - 10)
        
    }
    
    //MARK:- set data method
    func setCarouselData(paths:[String],describeTitle:[String],isAutoScroll:Bool,timer:Double?,defaultImage:String?) {
        
        if paths.count == 0 {
            return
        }
        timerInterval = timer
        defaultImg = defaultImage
        initWithData(paths,describeTitle)
        setImage(paths, currentIndex)
        setLabel(describeTitle, currentIndex)
        setScrollEnabled(paths, isAutoScroll)
    }
    
    //MARK:- set scroll method
    fileprivate func setScrollEnabled(_ url:[String],_ isAutoScroll:Bool) {
        
        stopAutoScroll()
        //setting auto scroll & more than one
        if isAutoScroll && url.count > 1 {
            scrollView.isScrollEnabled = true
            startAutoScroll()
        } else if url.count == 1 {
            scrollView.isScrollEnabled = false
        }
    }
    
    //MARK:- set first display view
    fileprivate func setImage(_ imageUrl:[String], _ curIndex:NSInteger) {
        
        if imageUrl.count == 0 {
            return
        }
        
        var beforeIndex = curIndex - 1
        let currentIndex = curIndex
        var afterIndex = curIndex + 1
        if beforeIndex < 0 {
            beforeIndex = imageUrl.count - 1
        }
        if afterIndex > imageUrl.count - 1 {
            afterIndex = 0
        }
        
        handleFirstImageView(currentImageView, imageUrl, curIndex)
        //more than one
        if imageUrl.count > 1 {
            handleFirstImageView(beforeImageView, imageUrl, beforeIndex)
            handleFirstImageView(afterImageView, imageUrl, afterIndex)
        }
        pageControl.numberOfPages = imageUrl.count
        pageControl.currentPage = currentIndex
        
        layoutSubviews()
        
    }
    
    
    fileprivate func handleFirstImageView(_ imageView:UIImageView,_ imageUrl:[String], _ curIndex:NSInteger) {
        
        if let delegate = delegate {
            if let method = delegate.callBackFirstDisplayView {
                method(imageView, imageUrl, curIndex)
                return
            }
        }
    }
    
    fileprivate func setLabel(_ describeTitle:[String], _ curIndex:NSInteger) {
        
        if describeTitle.count == 0 {
            return
        }
        
        describeLabel.text = describeTitle[curIndex]
    }
    
    //MARK:- change display view
    fileprivate func scrollToImageView(_ scrollDirect:direction) {
        
        if images.count == 0  {
            return
        }
        
        switch scrollDirect {
        case .none:
            
            break
        //right direct
        case .right:
            //change ImageView
            beforeImageView.image = currentImageView.image
            currentImageView.image = images[currentIndex]
            
            if currentIndex + 1 > images.count - 1 {
                afterImageView.image = images[0]
            } else {
                afterImageView.image = images[currentIndex + 1]
            }
            break
        //left direct
        case .left:
            //change ImageView
            afterImageView.image = currentImageView.image
            currentImageView.image =  images[currentIndex]
            
            if currentIndex - 1 < 0 {
                beforeImageView.image = images[images.count - 1]
            }else {
                beforeImageView.image = images[currentIndex - 1]
            }
            break
        }
        //chage Label
        describeLabel.text = describeString[currentIndex]
        scrollView.contentOffset = CGPoint.init(x: frame.size.width * 2, y: 0)
        
    }
    
    //MARK:- set auto scroll
    fileprivate func startAutoScroll() {
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: timerInterval ?? 5, target: self, selector: #selector(autoScrollToNextImageView), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func stopAutoScroll() {
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func autoScrollToNextImageView() {
        
        scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 3, y: 0), animated: true)
    }
    
    @objc fileprivate func autoScrollToBeforeImageView() {
        
        scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 1, y: 0), animated: true)
    }
    
    
    //MARK:- UITapGestureRecognizer
    @objc fileprivate func didSelectImageView() {
        
        if let delegate = delegate {
            if let method = delegate.didSelectCarouselView {
                method(self, currentIndex)
                return
            }
        }
    }
    
    
    //MARK:- UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if images.count == 0  {
            return
        }
        
        let width = scrollView.frame.width
        let currentPage = ((scrollView.contentOffset.x - width / 2) / width) - 1.5
        let scrollDirect = direction.init(rawValue: Int(currentPage))
        
        switch scrollDirect! {
        case .none:
            break
        default:
            handleIndex(scrollDirect!)
            scrollToImageView(scrollDirect!)
            break
        }
        
    }
    
    //MARK:- handle current index
    fileprivate func handleIndex(_ scrollDirect:direction) {
        
        switch scrollDirect {
        case .none:
            break
        case .right:
            currentIndex = currentIndex + 1
            if currentIndex == images.count {
                currentIndex = 0
            }
            break
        case .left:
            currentIndex = currentIndex - 1
            if currentIndex < 0 {
                currentIndex = images.count - 1
            }
            break
        }
        pageControl.currentPage = currentIndex
    }
    
    //MARK:- download all images
    fileprivate func downloadImages(_ url:String, _ index:Int) {
        
        delegate?.downloadImages(url, index)
    }
    
    //MARK:- public control method
    func startScrollImageView() {
        
        startAutoScroll()
    }
    
    func stopScrollImageView() {
        
        stopAutoScroll()
    }
    
   
    
}
