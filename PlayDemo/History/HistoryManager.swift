//
//  HistoryManager.swift
//  PlayDemo
//
//  Created by 李呱呱 on 2017/7/4.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

import Foundation

class HistoryManager: DatabaseManager {
    
    static let sharedInstance = HistoryManager();
    
    struct keyName {
        static let ID = "ID";
        static let title = "title";
        static let shortTitle = "shortTitle";
        static let img = "img";
        static let snsScore = "snsScore";
        static let playCount = "playCount";
        static let playCountText = "playCountText";
        static let aID = "aID";
        static let tvID = "tvID";
        static let isVip = "isVip";
        static let type = "type";
        static let pType = "pType";
        static let dateTimeStamp = "dateTimeStamp";
        static let dateFormat = "dateFormat";
        static let totalNum = "totalNum";
        static let updateNum = "updateNum";
        static let episode = "episode";
    }
    init() {
        super.init(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("History"), keyFile: "history.key", dataFile: "history.data");
    }
    
    func addHistory(history: ZPVideoInfo){
        let key = myKey;
        let data = myData;
        let keyExist = key.contains(history.id);
        let dataExist = data[history.id] != nil;
        let dict = [keyName.ID: history.id,
                    keyName.aID: history.aID,
                    keyName.dateFormat: history.dateFormat,
                    keyName.dateTimeStamp: history.dateTimeStamp,
                    keyName.episode: history.episode,
                    keyName.img: history.img,
                    keyName.isVip: history.isVip,
                    keyName.playCount: history.playCount,
                    keyName.playCountText: history.playCountText,
                    keyName.pType: history.pType.rawValue,
                    keyName.shortTitle: history.shortTitle,
                    keyName.snsScore: history.snsScore,
                    keyName.title: history.title,
                    keyName.totalNum: history.totalNum,
                    keyName.tvID: history.tvID,
                    keyName.type: history.type.rawValue,
                    keyName.updateNum: history.updateNum] as [String : Any];
        
        if !keyExist && !dataExist{
            objc_sync_enter(data);
            key.add(history.id);
            data[history.id] = dict;
            objc_sync_exit(data);
        }else if keyExist != dataExist{
            if keyExist{
                objc_sync_enter(data);
                data[history.id] = dict;
                objc_sync_exit(data);
            }else{
                key.add(history.id);
            }
        }
        write(data: data, key: key);
    }
    
    func getHistory(id: String) -> ZPVideoInfo?{
        let key = myKey;
        let data = myData;
        let keyExist = key.contains(id);
        let dataExist = data[id] != nil;
        if keyExist && dataExist{
            let history = ZPVideoInfo();
            if let dict = data[id] as? [String: Any]{
                history.id = dict[keyName.ID] as! String;
                history.aID = dict[keyName.aID] as! String;
                history.dateFormat = dict[keyName.dateFormat] as! String;
                history.dateTimeStamp = dict[keyName.dateTimeStamp] as! String;
                history.episode = dict[keyName.episode] as! UInt;
                history.img = dict[keyName.img] as! String;
                history.isVip = dict[keyName.isVip] as! String;
                history.playCount = dict[keyName.playCount] as! String;
                history.playCountText = dict[keyName.playCountText] as! String;
                history.pType = ZPVideoPropertyType(rawValue: dict[keyName.pType] as! UInt)!;
                history.shortTitle = dict[keyName.shortTitle] as! String;
                history.snsScore = dict[keyName.snsScore] as! Float;
                history.title = dict[keyName.title] as! String;
                history.totalNum = dict[keyName.totalNum] as! UInt;
                history.tvID = dict[keyName.tvID] as! String;
                history.type = ZPVideoType(rawValue: dict[keyName.type] as! UInt)!;
                history.updateNum = dict[keyName.updateNum] as! UInt;
                return history;
            }
        }
        return nil;
    }
    
    func getHistoryList() -> [String]{
        return myKey.copy() as! [String];
    }
}
