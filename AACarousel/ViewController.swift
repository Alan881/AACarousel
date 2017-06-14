//
//  ViewController.swift
//  AACarousel
//
//  Created by Alan on 2017/6/11.
//  Copyright © 2017年 Alan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,AACarouselDelegate {
    @IBOutlet weak var carouselView: AACarousel!

    override func viewDidLoad() {
        super.viewDidLoad()
     
        let pathArray = ["http://www.gettyimages.ca/gi-resources/images/Embed/new/embed2.jpg",
                        "very-large-flamingo",
                        "https://imgct2.aeplcdn.com/img/800x600/car-data/big/honda-amaze-image-12749.png",
                        "http://www.conversion-uplift.co.uk/wp-content/uploads/2016/09/Lamborghini-Huracan-Image-672x372.jpg",
                        "https://ak.picdn.net/assets/cms/97e1dd3f8a3ecb81356fe754a1a113f31b6dbfd4-stock-photo-photo-of-a-common-kingfisher-alcedo-atthis-adult-male-perched-on-a-lichen-covered-branch-107647640.jpg"]
        let titleArray = ["picture 1","picture 2","picture 3","picture 4","picture 5"]
        carouselView.delegate = self
        carouselView.setCarouselData(paths: pathArray,  describeTitle: titleArray, isAutoScroll: true, timer: 5.0, defaultImage: "defaultImage")
    }
    
    //require method
    func downloadImages(_ url: String, _ index:Int) {
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: url)!, placeholder: nil, options: [.transition(.fade(0))], progressBlock: nil, completionHandler: { (downloadImage, error, cacheType, url) in
            self.carouselView.images[index] = downloadImage!
        })
        
    }
    
    //optional method
    func didSelectCarouselView(_ view:AACarousel ,_ currInex:Int) {
        
    }
    
    //optional method
    func callBackFirstDisplayView(_ imageView: UIImageView, _ imageUrl: [String], _ currInex: Int) {
        
        imageView.kf.setImage(with: URL(string: imageUrl[currInex]), placeholder: nil, options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

