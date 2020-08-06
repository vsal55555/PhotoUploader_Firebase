//
//  ViewController.swift
//  PhotoUploader_Firebase
//
//  Created by BSAL-MAC on 7/29/20.
//  Copyright © 2020 BSAL-MAC. All rights reserved.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    private let storage = Storage.storage().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.numberOfLines = 0
        label.textAlignment = .center
        imageView.contentMode = .scaleAspectFit
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
            let url = URL(string: urlString) else {
            return
        }
        label.text = urlString
        let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        })
        task.resume()
    }

    @IBAction func didtapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    //this method is called whem user finishes to pick/grab the photos
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }//get byte from the data out of it
        //we are not uploading the image we are uploading the bytes for that image
        //later we can download those bytes and convert to our images
        guard let imageData = image.pngData() else {
            return
        }
        /*
         Desktop/file.png
         */
        
        storage.child("images/file.png").putData(imageData, metadata: nil, completion: { _, error in
            //validate
            guard error == nil else {
                print("Failed to upload")
                return
            }
            self.storage.child("images/file.png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                print("Download url: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            })
            
        })
        //upload image data
        //get download url
        //save download url to userdefault
    }
    
    //when picker is cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
}

