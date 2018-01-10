//
//  ViewController.swift
//  ImageRecognizer
//
//  Created by Alexandr on 1/9/18.
//  Copyright © 2018 Alexandr. All rights reserved.
//


// использовать 2 потока для обработки картинки
// типа 5000 пикселей в одном и во втором 5000


import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBAction func pressTryButton(_ sender: UIButton) {
        handleButton()
    }
    private func handleButton(){
        
        if verifyUrl(urlString: urlTextField.text) {
            downloadImageFromURL(urlString: urlTextField.text!)
        } else {
            print("Not URL")
        }

    }
    private func downloadImageFromURL(urlString: String) {
        
        let getImageFromUrl = URLSession(configuration: .default).dataTask(with: URL(string: urlString)!) { (data, response, error) in
            
            if error != nil {
                self.showToast(message: "Error")
                print("Error Occurred")
                
            } else {
                print(response!.mimeType!)
                let imageTypes = ["image/jpeg","image/png"]
                if imageTypes.contains(response!.mimeType!) {
                    if let image = UIImage(data: data!) {
                        DispatchQueue.main.async {
                            self.showToast(message: "Success")
                            self.customImage.image = self.processPixels(in: image)
//                            self.customImage.image = image
                        }
                    }
                } else {
                    self.showToast(message: "Not an image")
                }
            }
        }

        getImageFromUrl.resume()
    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func processPixels(in image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                for i in 10...255{
                    let mygreen = RGBA32(red: 0,   green: UInt8(i), blue: 0,   alpha: 255)
                    if pixelBuffer[offset] == mygreen{
                        pixelBuffer[offset] = .red
                    }
                }
                
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }
    private func showToast(message : String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }

}
