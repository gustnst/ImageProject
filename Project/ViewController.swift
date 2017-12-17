//
//  ViewController.swift
//  Project
//
//  Created by Admin on 08.12.2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
   // 96 111 72 87   4 19 72 87

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Image(image: #imageLiteral(resourceName: "Image-2"))
      //  var m = image?.makeWindow(image: image!, xFrom: 4 ,xTo: 19, yFrom: 72, yTo: 87)
        // imageView.image=m?.toUIImage()
       imageView.image = image?.getKeyPoints(image: image!, windowSize: 16).toUIImage()

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

