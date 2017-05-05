//
//  Network.swift
//  ThemeUIExample
//
//  Created by EnzoLiu on 2017/5/5.
//  Copyright © 2017年 EnzoLiu. All rights reserved.
//

import Foundation
import UIKit

func HTTPGet(_ url: String, timeout: TimeInterval = 30, callback: @escaping (Data?, String?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let nsUrl = URL(string: url ?? "") {
            var request = URLRequest(url: nsUrl, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: timeout)
            request.httpMethod = "GET"
            HTTPsendRequest(request, timeout: timeout, callback: callback)
        }
    }
}

func HTTPsendRequest(_ request: URLRequest, timeout: TimeInterval, callback: @escaping (Data?, String?) -> Void) {
    var bgTask = UIBackgroundTaskInvalid
    bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {() -> Void in
        UIApplication.shared.endBackgroundTask(bgTask)
    })
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {
        data, response, error in
        guard let data = data else {
            callback(nil, "ServerReturnsEmptyData")
            return
        }
        callback(data, nil)
        UIApplication.shared.endBackgroundTask(bgTask)
    })
    task.resume()
}
