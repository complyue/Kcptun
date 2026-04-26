//
//  Launch.swift
//  KcpProxy
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class KcpProxy {
    let clientBinary = Bundle.main.path(forResource: "client_darwin_amd64", ofType: nil)
    static let shared = KcpProxy()
    private var task: Process?
    // When true, the KCPROXY_STOP notification will NOT update KcpProxyOn.
    // Used when app is quitting so KcpProxyOn persists for next auto-start.
    private var isQuitting = false
    
    func start() {
        if let t = self.task, t.isRunning {
            return
        }
        self.task = Process()
        CommandLine.async(task: self.task!, shellPath: self.clientBinary!, arguments: Profile.shared.arguments(), terminate:  { (finish) in
            print("KcpProxy turn off!")
            // Only post KCPROXY_STOP if NOT quitting (quit handles kill directly).
            if !self.isQuitting {
                NotificationCenter.default.post(name: KCPROXY_STOP, object: nil)
            }
        })
    }
    
    func stop() {
        if let t = self.task {
            t.terminate()
            t.waitUntilExit()
        }
        self.task = nil
    }
    
    func stopForQuit() {
        // Called only when app is quitting.
        // Terminate the process directly without posting KCPROXY_STOP
        // so KcpProxyOn stays true for next auto-start.
        isQuitting = true
        if let t = self.task {
            t.terminate()
        }
        self.task = nil
    }
}

