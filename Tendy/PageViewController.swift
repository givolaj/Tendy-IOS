//
//  PageViewController.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class PageViewController: UIViewController , UIPageViewControllerDataSource,UIPageViewControllerDelegate
{
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegiter: UIButton!
    
    @IBAction func pageControllerValueChanged(_ sender: AnyObject) {
        let currentIndex = pageController.currentPage
        let startingViewController: PageContentViewController = viewControllerAtIndex(currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController?.setViewControllers( viewControllers, direction: .forward , animated: true, completion:pageNumbr)
    }
    @IBOutlet weak var btnGoRegister: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    //constarin to ipad
    @IBOutlet weak var conPageControllerBottom: NSLayoutConstraint!
    @IBOutlet weak var conBtnRegisterHeight: NSLayoutConstraint!
    
    
    var pageViewController : UIPageViewController?

    var pageTitles : Array<String> = ["pageTitle1".localized,"pageTitle2".localized,"pageTitle3".localized]
    var pageImages : Array<String> = ["1", "2", "3"]
    var pageCenterText : Array<String> = ["pageCenterText1".localized,"pageCenterText2".localized,"pageCenterText3".localized]
    var textClr: Array<UIColor> = [UIColor.exDarkGray,UIColor.exDarkGray,UIColor.white]
    var lineClr: Array<UIColor> = [UIColor.extYellow,UIColor.exGreen,UIColor.exGreen]
    
    var currentIndex : Int = 0
    var timer:Timer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnRegiter.isHidden=true
        pageController.numberOfPages=pageImages.count
        pageController.currentPage=0
        pageController.currentPageIndicatorTintColor=UIColor.white
        pageController.transform = CGAffineTransform(scaleX: 2, y: 2); //set value here
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController!.dataSource = self
        pageViewController!.delegate=self
        let startingViewController: PageContentViewController = viewControllerAtIndex(0)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height);
        addChildViewController(pageViewController!)
        self.view.insertSubview(pageViewController!.view, at: 0)
        pageViewController!.didMove(toParentViewController: self)
        startTimer()
        
        btnRegiter.setTitle( "GOT IT".localized, for: .normal)
        if DeviceType.IS_IPAD {
            setIpadConstrains()
        }
        
    }
    
    func setIpadConstrains(){
        conPageControllerBottom.constant = 25//60
        conBtnRegisterHeight.constant = 25//40
        btnRegiter.titleLabel?.font = btnRegiter.titleLabel?.font.withSize(20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    
    func startTimer()
    {
        // timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(PageViewController.update), userInfo: nil, repeats: true)
    }
    
    
    
    
    func update() {
        let currentIndex = (self.pageViewController!.viewControllers!.last as! PageContentViewController).pageIndex+1
        if(currentIndex<pageImages.count)
        {
            let startingViewController: PageContentViewController = viewControllerAtIndex(currentIndex)!
            let viewControllers = [startingViewController]
            pageViewController?.setViewControllers( viewControllers, direction: .forward , animated: true, completion:pageNumbr)
        }
        else
        {
            timer.invalidate()
        }
        
    }
    
    func pageNumbr(_ succ:Bool)
    {
        pageController.currentPage = currentIndex;
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed)
        {
            return;
        }
        let currentIndex = (self.pageViewController!.viewControllers!.last as! PageContentViewController).pageIndex
        pageController.currentPage = currentIndex;
        btnRegiter.isHidden=(currentIndex == self.pageTitles.count-1) ? false :  true
        
        //timer.invalidate()
        if(currentIndex<pageImages.count-1)
        {
            startTimer()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        
        var index = (viewController as! PageContentViewController).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PageContentViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if (index == self.pageTitles.count) {
            
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController?
    {
        
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return nil
        }
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController")   as! PageContentViewController
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.titleText = pageTitles[index]
        pageContentViewController.centerText = pageCenterText[index]
        pageContentViewController.textColor = textClr[index]
        pageContentViewController.lineColor = lineClr[index]
        
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserDefaults.standard.set(true, forKey:C.userDef.showInstructions )
        UserDefaults.standard.synchronize()
        //   timer.invalidate()
        
    }
    
}
