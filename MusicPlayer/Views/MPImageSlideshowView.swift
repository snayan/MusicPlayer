//
//  MPImageSlideshowView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/5.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

fileprivate class SSImageView: UIImageView {
    
    enum Status {
        case unload
        case loading
        case loaded
    }
    
    override var image: UIImage? {
        didSet {
            if image == nil {
                self.status = .unload
            } else {
                self.status = .loaded
            }
        }
    }
    
    var src: String?
    
    fileprivate(set) var status: Status
    
    
    required init?(coder aDecoder: NSCoder) {
        status = .unload
        super.init(coder: aDecoder)
    }
    
    override init(image: UIImage?) {
        status = image == nil ? .unload : .loaded
        super.init(image: image)
    }
    
    override init(frame: CGRect) {
        status = .unload
        super.init(frame: frame)
    }
    
    convenience init(src: String?) {
        self.init(image: nil)
        self.src = src
    }
    
    convenience init() {
        self.init(image: nil)
    }
    
    func loadImage() {
        guard self.status == .unload else {
            return
        }
        
        guard let src = src, let url = URL.ATS(string: src) else {
            return
        }
    
        status = .loading
        MPBaseURLSession.getImage(withUrl: url) { image, error in
            guard self.status == .loading else {
                return
            }
            guard let image = image, error == nil else {
                self.status = .unload
                return
            }
            DispatchQueue.main.async {
                self.image = image
                self.status = .loaded
            }
        }
    }
    
}

class MPImageSlideshowView: UIView {
    
    // MARK: fileprivate property
    
    fileprivate let scrollView: UIScrollView = UIScrollView()
    fileprivate let indicator: UIPageControl = UIPageControl()
    fileprivate var slideshowTimer: Timer?
    fileprivate var slideshowImages: [SSImageView] = []
    fileprivate var showPage: Int = 0 {
        didSet {
            let nextShowPage = showPage % slideshowImages.count
            let nextCurrentPage = showPage % data.count
            guard nextCurrentPage != currentPage else {
                return ()
            }
            if let delegate = delegate {
                if !delegate.pageWillChanged(currentPage) {
                    showPage = oldValue
                    return ()
                }
            }
            showPage = nextShowPage
            currentPage = nextCurrentPage
            setVisiblePage(nextShowPage)
            delegate?.pageDidChanged(nextCurrentPage)
        }
    }
    fileprivate(set) var currentPage: Int = 0 {
        didSet {
            currentPage = currentPage % data.count
            indicator.currentPage = currentPage
        }
    }
    
    //MARK: confiurable property
    
    weak var delegate: MPImageSlideshowDelegate?
    
    var data1: [UIImage] = [] {
        didSet {
            scrollView.isScrollEnabled = data1.count > 1
            indicator.numberOfPages = data1.count
            reloadScrollView()
        }
    }
    var data: [String] = [] {
        didSet {
            scrollView.isScrollEnabled = data.count > 1
            indicator.numberOfPages = data.count
            reloadScrollView()
        }
    }
    var interval: Double = 0.0 {
        didSet {
            // 重新设置了播放间隔
            inValidateTimer()
            setTimerIfNeed()
        }
    }
    var indicatorMarginBottom: CGFloat? = nil {
        didSet {
            layoutIndicator()
        }
    }
    var circular: Bool = true {
        didSet {
            // 设置了循环显示
            reloadScrollView()
        }
    }
    var draggingEnabled: Bool = true {
        didSet {
            // 是否允许拖拽
            scrollView.isUserInteractionEnabled = draggingEnabled
        }
    }
    // 预先加载图片数量,bug：下拉再回去时，有时没显示出来图片，所以先设置预先加载所有的图片
    var preLoadCount: Int = 100 {
        didSet {
            if preLoadCount < 2 {
                preLoadCount = 2
            }
        }
    }
    
    
    // MARK: initilizar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    fileprivate func setup() {

        scrollView.delegate = self
        scrollView.isScrollEnabled = data.count > 1
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.clipsToBounds = true
        scrollView.autoresizesSubviews = true
        scrollView.autoresizingMask = autoresizingMask
        scrollView.contentInsetAdjustmentBehavior = .never
        
        indicator.hidesForSinglePage = true
        indicator.defersCurrentPageDisplay = false
        indicator.numberOfPages = data.count
        
        addSubview(scrollView)
        addSubview(indicator)
        layoutScrollView()
        layoutIndicator()
        setTimerIfNeed()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
    }
    
    func inValidateTimer() {
        if slideshowTimer?.isValid != nil {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }
    }
    
    func setTimerIfNeed() {
        if interval > 0  && data.count > 1 && slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(MPImageSlideshowView.slideshowTick), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func reloadScrollView() {
        inValidateTimer()
        for imageView in slideshowImages {
            imageView.removeFromSuperview()
        }
        setSlideshowImage()
        layoutScrollView()
        setTimerIfNeed()
    }
    
    fileprivate func layoutScrollView() {
        let width = frame.size.width
        scrollView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        scrollView.contentSize = CGSize(width: width*CGFloat(slideshowImages.count), height: frame.size.height)
        for (index, imageView) in slideshowImages.enumerated() {
            imageView.frame = CGRect(origin: CGPoint(x: width*CGFloat(index), y: 0), size: frame.size)
            scrollView.addSubview(imageView)
        }
    }
    
    fileprivate func layoutIndicator() {
        indicator.snp.makeConstraints{ make in
            let btoomContraint = make.bottom.equalToSuperview()
            if let indicatorMarginBottom = indicatorMarginBottom {
                btoomContraint.offset(indicatorMarginBottom)
            }
            make.centerX.equalToSuperview()
        }
    }
    
    fileprivate func setSlideshowImage() {
        let originImageViews: [SSImageView] = data.map{SSImageView(src: $0)}
        var copyImageViews: [SSImageView] = []
        if circular {
            copyImageViews = data.map{SSImageView(src: $0)}
        }
        var index: Int = 0
        slideshowImages = [originImageViews, copyImageViews].flatMap{$0}.map{ imageView in
            if index < preLoadCount {
                imageView.loadImage()
            }
            index = index + 1
            scrollView.addSubview(imageView)
            return imageView
        }
    }
    
    fileprivate func setVisiblePage(_ showPage: Int) {
        if showPage < slideshowImages.count {
            let visibleRect = CGRect(x: scrollView.bounds.width*CGFloat(showPage), y: scrollView.frame.origin.y, width: scrollView.bounds.width, height: scrollView.bounds.height)
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }
    
    @objc fileprivate func slideshowTick(_ timer: Timer) {
        if data.count > 1 {
            showPage = showPage + 1
        }
    }
    
}

extension MPImageSlideshowView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        inValidateTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setTimerIfNeed()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if circular {
            let width = scrollView.frame.size.width
            let regularContentOffset = width * CGFloat(data.count)
            if scrollView.contentOffset.x >= regularContentOffset * 2 - width {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - regularContentOffset, y: 0)
                showPage = data.count - 1
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let frameWidth = scrollView.frame.width
        if frameWidth > 0 {
            let offsetPage = Int(scrollView.contentOffset.x) / Int(frameWidth)
            currentPage = offsetPage % data.count
            if offsetPage != showPage {
                showPage = offsetPage
            }
        }
    }
}

