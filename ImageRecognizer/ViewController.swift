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
                            self.customImage.image = image
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
