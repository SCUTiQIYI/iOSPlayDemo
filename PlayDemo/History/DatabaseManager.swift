//
//  DatabaseManager.swift
//  Crabfans_2017
//
//  Created by 李呱呱 on 2017/6/14.
//  Copyright © 2017年 liguagua. All rights reserved.
//

import Foundation

class DatabaseManager:NSObject {
    
    internal var myData:NSMutableDictionary{
        get{
            return read().data;
        }
    };
    internal var myKey: NSMutableArray{
        get{
            return read().key;
        }
    }
    
    var folderUrl:URL;
    var keyFileName:String;
    var dataFileName:String;
    
    init(url: URL, keyFile: String, dataFile: String){
        folderUrl = url;
        keyFileName = keyFile;
        dataFileName = dataFile;
    }
    
    internal func getTimeStamp() -> String {
        let time = Date();
        let timeFormatter = DateFormatter();
        timeFormatter.dateFormat = "yyyyMMddHHmmss";
        return "\(timeFormatter.string(from: time))";
    }
    
    internal func getRandomID() -> Int{
        return -("\(getTimeStamp())+\(arc4random_uniform(1000))" as NSString).integerValue
    }
    
    internal func read() -> (data:NSMutableDictionary,key:NSMutableArray) {
        let dataUrl = folderUrl.appendingPathComponent(dataFileName);
        let keyUrl = folderUrl.appendingPathComponent(keyFileName);
        do{
            let dataExist = FileManager.default.fileExists(atPath: dataUrl.path);
            let keyExist = FileManager.default.fileExists(atPath: keyUrl.path)
            if dataExist && !keyExist{
                let dict = NSMutableDictionary(contentsOfFile: dataUrl.path)!;
                let emptyKey = NSMutableArray();
                for (key,_) in dict {
                    emptyKey.add(key);
                }
                emptyKey.write(toFile: keyUrl.path, atomically: true);
            }else if !dataExist || !keyExist
            {
                try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil);
                let emptyData = NSMutableDictionary();
                emptyData.write(toFile: dataUrl.path, atomically: true);
                let emptyKey = NSMutableArray();
                emptyKey.write(toFile: keyUrl.path, atomically: true);
            }
        }catch{
            print(error.localizedDescription);
        }
        let dict = NSMutableDictionary(contentsOfFile: dataUrl.path)!;
        let key = NSMutableArray(contentsOfFile: keyUrl.path)!;
        
        return (dict,key);
    }
    
    internal func write(data: NSMutableDictionary, key: NSMutableArray) {
        let dataUrl = folderUrl.appendingPathComponent(dataFileName);
        let keyUrl = folderUrl.appendingPathComponent(keyFileName);
        let dataExist = FileManager.default.fileExists(atPath: dataUrl.path);
        let keyExist = FileManager.default.fileExists(atPath: keyUrl.path);
        if !dataExist && !keyExist {
            try! FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil);
        }
        data.write(toFile: dataUrl.path, atomically: true);
        key.write(toFile: keyUrl.path, atomically: true);
    }
    
    func selectEqual(value: AnyObject, with Key: String) -> [(key:String, value:Any)] {
        return myData.filter({ value.isEqual(($1 as! [String: Any])[Key]) }) as! [(key:String, value:Any)];
    }
    
    func selectContain(value: String, with Key: String) -> [(key: String, value: Any)]{
        return myData.filter({ (_, v) -> Bool in
            if let des = (v as AnyObject).description{
                return des.contains(value);
            }
            return false;
        }) as! [(key: String, value: Any)];
    }
}
