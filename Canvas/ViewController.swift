//
//  ViewController.swift
//  Canvas
//
//  Created by Роман Смоляков on 03/11/2018.
//  Copyright © 2018 Роман Смоляков. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var canvasView: CanvasView!

    var request = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }
    
    func setupVision(){
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model)
            else { fatalError("can not load VISION ML model")}
        
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        self.request = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("No result"); return
        }
        
        let classifications = observations.flatMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.99})
            .map({$0.identifier})
        
        
        DispatchQueue.global().async(execute: {
           
            DispatchQueue.main.sync{
                self.labelResult.text = classifications.first
                self.canvasView.clearCanvas()
            }
        })
        
    }

    @IBAction func btnClearAction(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func btnRecognizeAction(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.request)
        }catch{
            print(error)
        }
    }
    
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

