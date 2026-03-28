//
//  S3BucketHelper.swift
//  BTYB
//
//  Created by Yogyata on 28/01/25.
//

import Foundation
import UIKit
import AWSS3
import AWSCore
import UniformTypeIdentifiers

var accessKey =   UserCache.accessKey()
var secretKey =   UserCache.secretKey()
var bucket =      UserCache.bucket()
var seprator =    bucket + "/"

//let regionKey = AWSRegionType.USEast2
let regionString = UserCache.region()
// Map region string to AWSRegionType

let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1, credentialsProvider: credentialsProvider)
typealias progressBlock = (_ progress: Double) -> Void //2
typealias completionBlock = (_ response: Any?, _ fileName : String? , _ error: Error?) -> Void //3

class AWSService {
    var preSignedURLString = ""
    func setUpAWS(){
        let region: AWSRegionType
        switch regionString.lowercased() {
        case "us-east-2": region = .USEast2
        case "ap-south-1": region = .APSouth1
        default: region = .USEast2
        }
        //Using Open mode
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration.init(region: region, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
       
    }
    //MARK: - TO DELETE IMAGE LIST IN BUCKET WITH SIZE
    class func deleteMedia(with shortURL: String) {
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = bucket
        deleteObjectRequest?.key = AWSService().getPreSignedURL(S3DownloadKeyName: shortURL)
        AWSS3.default().deleteObject(deleteObjectRequest!).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                print("Error deleting image: \(error.localizedDescription)")
            } else {
                print("Image deleted successfully.")
            }
            return nil
        }
    }
    
    
    class func uploadVideo(imageURL : URL, publisherImages :String, userName : String, view: UIView ,completetionBlock: @escaping (String?, String?) -> Void) {
        
        
        DispatchQueue.main.async {
            LoaderHelper.shared.startLoader(view)
        
        }
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let timeStamp =  Date().timeIntervalSince1970
        let milliseconds = Int(timeStamp * 1000.0)
        let name =  userName
        //let imageName = name + "." +  "mp4"
        let remoteName = publisherImages + name + "_" +  "\(milliseconds)"
        let uploadRequest = AWSS3CreateMultipartUploadRequest()!
        
        //   uploadRequest.body = fileUrl as URL
        uploadRequest.key = remoteName + ".mp4"
        uploadRequest.bucket = bucket
        uploadRequest.contentType = "video/mp4"
        uploadRequest.acl = AWSS3ObjectCannedACL.publicRead
        
        var publicVideoUrlString = String()
        var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock?
        
        completionHandler =  { (task, err) in
            DispatchQueue.main.async(execute: {
                completetionBlock(publicVideoUrlString,nil)
                
                DispatchQueue.main.async {
                    LoaderHelper.shared.stopLoader()
                }
            })
        }
        
        let key =  remoteName + ".mp4"
        let contentType = "video/mp4"
        let transferUtility = AWSS3TransferUtility.default()
        
        
        transferUtility.uploadUsingMultiPart(fileURL: imageURL as URL, bucket: bucket, key: key, contentType: contentType, expression: nil, completionHandler: completionHandler).continueWith{ (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    LoaderHelper.shared.stopLoader()
                }
            }
            
            if task.result != nil{
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                
                if url != nil{
                    let str = String(describing: publicURL!)
                    let strArr = str.components(separatedBy: seprator)
                    publicVideoUrlString = strArr.last!
                    
                    //                    if !StaticHelper.shared.isInternetConnected {
                    //                        DispatchQueue.main.async {
                    //                            StaticHelper.shared.stopLoader()
                    //                        }
                    //                    }
                } else {
                    //netChecK()
                }
            }
            else {
                DispatchQueue.main.async {
                    LoaderHelper.shared.stopLoader()
                }
            }
            return nil
        }
        return
    }
    
    func getPublicURL(for key: String) -> String {
        let endpoint = "https://\(bucket).s3.amazonaws.com"
        return "\(endpoint)/\(key)"
    }

    func getPreSignedURL( S3DownloadKeyName: String)->String{
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPreSignedURLRequest.key = S3DownloadKeyName
        getPreSignedURLRequest.bucket = bucket
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 7 * 24 * 60 * 60)//Date(timeIntervalSinceNow: 3600)
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            } else {
                self.preSignedURLString = (task.result?.absoluteString)!
                return nil
            }
        }
        return self.preSignedURLString
    }
    
}
class S3BucketHelper: NSObject {
    class func getFileSize(filePath: String) -> Double{
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            return (Double(attr[FileAttributeKey.size] as! UInt64 ))
            //if you convert to NSDictionary, you can get file size old way as well.
            //            let dict = attr as NSDictionary
            //            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        return 0
    }
    
//    class func uploadImageOnAws(imgdata:Data?, publisherImages :String, userName : String, view: UIView ,completetionBlock: @escaping (String?, String?) -> Void) {
//        
//        DispatchQueue.main.async {
//            LoaderHelper.shared.startLoader(view)
//        }
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//        
//        let uuid = UUID().uuidString
//        
//        // let timeStamp =  Date().timeIntervalSince1970
//        // let milliseconds = Int(timeStamp * 1000.0)
//        
//        let fileManager = FileManager.default
//        let name =  userName
//        let imageName = name + "." + "jpeg"
//        //  let remoteName = publisherImages + name + "_" +  "\(uuid)"
//        let remoteName = publisherImages + name + "\(uuid)"
//        //"\(strArr[0])"
//        
//        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
//        fileManager.createFile(atPath: path as String, contents: imgdata, attributes: nil)
//        let fileUrl = NSURL(fileURLWithPath: path)
//        
//        //  var file_size = S3BucketHelper.getFileSize(filePath: path)
//        let uploadRequest = AWSS3CreateMultipartUploadRequest()!
//        //   uploadRequest.body = fileUrl as URL
//        uploadRequest.key = remoteName + ".jpeg"
//        uploadRequest.bucket = bucket
//        uploadRequest.contentType = "image/jpeg"
//        uploadRequest.acl = AWSS3ObjectCannedACL.publicRead
//        
//        var publicVideoUrlString = String()
//        var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock?
//        completionHandler =  { (task, err) in
//            DispatchQueue.main.async(execute: {
//                completetionBlock(publicVideoUrlString,nil)
//                DispatchQueue.main.async {
//                    
//                    LoaderHelper.shared.stopLoader()
//                }
//                // Do something e.g. Alert a user for transfer completion.
//                // On failed uploads, `error` contains the error object.
//            })
//        }
//        
//        let key =  remoteName + ".jpeg"
//        let contentType = "image/jpeg"
//        let transferUtility = AWSS3TransferUtility.default()
//        
//        transferUtility.uploadUsingMultiPart(fileURL: fileUrl as URL, bucket: bucket, key: key, contentType: contentType, expression: nil, completionHandler: completionHandler).continueWith{ (task) -> AnyObject? in
//            if let error = task.error {
//                print("Error: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    LoaderHelper.shared.stopLoader()
//                }
//            }
//            if task.result != nil{
//                let url = AWSS3.default().configuration.endpoint.url
//                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
//                
//                
//                if url != nil{
//                    let str = String(describing: publicURL!)
//                    let strArr = str.components(separatedBy: seprator)
//                    //    try?   fileManager.removeItem(at: fileUrl as URL)
//                    
//                    publicVideoUrlString = strArr.last!
//                    //  completetionBlock(publicVideoUrlString,nil)
//                    print("Uploaded to:\(String(describing: publicURL!))")
//                    // self.profilePicURL = strArr[1]
//                }
//            }
//            else {
//                print("Unexpected empty result.")
//                DispatchQueue.main.async {
//                    LoaderHelper.shared.stopLoader()
//                }
//            }
//            return nil
//        }
//        
//        return
//    }
    
    class func uploadImageOnAws(imgdata: Data?,
                                publisherImages: String,
                                userName: String,
                                view: UIView,
                                completetionBlock: @escaping (String?, String?) -> Void) {
        
        guard let imgdata = imgdata else {
            completetionBlock(nil, "No image data")
            return
        }

        AWSConfigManager.configureS3()   // ← ensures latest keys used

        DispatchQueue.main.async { LoaderHelper.shared.startLoader(view) }

        let uuid = Int(Date().timeIntervalSince1970)
        let key = "\(publisherImages)\(userName)_\(uuid).jpeg"   // FIXED KEY FORMAT

        let fileName = "\(userName).jpeg"
        let filePath = NSTemporaryDirectory() + fileName
        FileManager.default.createFile(atPath: filePath, contents: imgdata, attributes: nil)

        let fileURL = URL(fileURLWithPath: filePath)

        let expression = AWSS3TransferUtilityMultiPartUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")

        let completion: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock = { task, error in
            DispatchQueue.main.async {
                LoaderHelper.shared.stopLoader()
                if let error = error {
                    completetionBlock(nil, error.localizedDescription)
                } else {
                    completetionBlock(key, nil)
                }
            }
        }

        AWSS3TransferUtility.default().uploadUsingMultiPart(
            fileURL: fileURL,
            bucket: UserCache.bucket(),
            key: key,
            contentType: "image/jpeg",
            expression: expression,
            completionHandler: completion
        )
    }

    
    class func netChecK() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "No Internet", message: "Please check your connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            
            LoaderHelper.shared.stopLoader()
        }
    }
}

class AWSConfigManager {
    static func configureS3() {
        let access = UserCache.accessKey()
        let secret = UserCache.secretKey()
        let bucket = UserCache.bucket()
        let regionString = UserCache.region()

        guard !access.isEmpty, !secret.isEmpty, !bucket.isEmpty else {
            print("❌ Missing AWS credentials")
            return
        }

        let region = regionString.awsRegionType

        let credentials = AWSStaticCredentialsProvider(accessKey: access, secretKey: secret)
        let config = AWSServiceConfiguration(region: region, credentialsProvider: credentials)

        AWSServiceManager.default().defaultServiceConfiguration = config

        print("✅ AWS S3 Initialized Successfully with region:", regionString)
    }
}

extension String {
    var awsRegionType: AWSRegionType {
        switch self {
        case "us-east-1": return .USEast1
        case "us-east-2": return .USEast2
        case "ap-south-1": return .APSouth1
        case "ap-southeast-1": return .APSoutheast1
        default: return .USEast1
        }
    }
}


func s3PublicURL(for key: String) -> String {
    let bucket = UserCache.bucket()
    let region = UserCache.region()

    if region == "us-east-1" {
        return "https://\(bucket).s3.amazonaws.com/\(key)"
    }

    return "https://\(bucket).s3.\(region).amazonaws.com/\(key)"
}
