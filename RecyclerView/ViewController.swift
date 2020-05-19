//
//  ViewController.swift
//  RecyclerView
//
//  Created by zhengyi on 2020/5/19.
//  Copyright © 2020 zhengyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let banner = BBPegasusBannerView(frame: CGRect(x: 10, y: 100, width: view.frame.width-20, height: (view.frame.width-20)/16*9))
        view.addSubview(banner)
        
        var arr = [Int]();
        for i in 0...5 {
            arr.append(i)
        }
        banner.install(withItems: arr, customItemCellClass: nil)
    }
}

