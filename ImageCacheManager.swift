//
//  ImageCacheManager.swift
//  ThanksAgain
//
//  Created by Piotr Torczyski on 16/02/16.
//  Copyright © 2016 SoInteractive S.A. All rights reserved.
//

import UIKit
import Alamofire

class ImageCacheManager {
	
	func getImageFromURL(imageURL : NSURL, callback: (image: UIImage?) -> Void) {
		
		let url : NSString = String(imageURL)
		let lastComponent = url.lastPathComponent
		let arrayOfComponents = lastComponent.componentsSeparatedByString("=")
		let imageID = arrayOfComponents.last
		
		getImageFromLocalStorage(imageID!) { (image) -> Void in
			if image != nil {
				callback(image: image)
			}
			else
			{
				self.getImageFromRemote(imageURL, imageID: imageID!, callback: { (image) -> Void in
					callback(image: image)
				})
			}
		}
	}
	
	private func getImageFromLocalStorage(imageID : NSString, callback: (image: UIImage?) -> Void) {
		
		let imageName = "\(imageID).png"
		let fileManager = NSFileManager.defaultManager()
		
		var docsDir: String?
		var dataFile: String?
		let filePath = "/" + imageName
		let dirPaths = NSSearchPathForDirectoriesInDomains(
				.DocumentDirectory, .UserDomainMask, true)
		
		docsDir = dirPaths[0] as? String
		dataFile = (docsDir?.stringByAppendingString(filePath))!
		
		if fileManager.fileExistsAtPath(dataFile!) {
			callback(image: UIImage(contentsOfFile: dataFile!))
		}
		else {
			callback(image: nil)
		}
	}
	
	private func getImageFromRemote(imageURL : NSURL, imageID: String, callback: (image: UIImage?) -> Void) {
		request(.GET, imageURL).response() {
			(_, _, data, _) in
			
			let downloadedImage: UIImage? = UIImage(data: data! as NSData)!
			if downloadedImage != nil {
				
				callback(
					image: downloadedImage
				)
				self.saveToLocatStorage(data!, fileName: imageID)
			}
			else
			{
				debugPrint("Image from \(imageURL) couldn't be downloaded.")
			}
		}
	}
	
	private func saveToLocatStorage(imageToSave : NSData, fileName: String) {
		
		let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		
		if let image = UIImage(data: imageToSave) {
			let fileURL = documentsURL.URLByAppendingPathComponent(fileName + ".png")
			if let pngImageData = UIImagePNGRepresentation(image) {
				pngImageData.writeToURL(fileURL, atomically: false)
			}
		}
	}
}
