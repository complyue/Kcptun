//
//  Launch.swift
//  KcpProxy
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class KcpProxy {
    let kcptun = Bundle.main.path(forResource: "client_darwin_amd64", ofType: nil)
    static let shared = KcpProxy()
    private var task: Process?
    // When true, the KCPTUN_STOP notification will NOT update KcpProxyOn.
    // Used when app is quitting so KcpProxyOn persists for next auto-start.
    private var isQuitting = false
    
    func start() {
        if let t = self.task, t.isRunning {
            return
        }
        self.task = Process()
        CommandLine.async(task: self.task!, shellPath: self.kcptun!, arguments: Profile.shared.arguments(), terminate:  { (finish) in
            print("KcpProxy turn off!")
            // Only post KCPTUN_STOP if NOT quitting (quit handles kill directly).
            if !self.isQuitting {
                NotificationCenter.default.post(name: KCPTUN_STOP, object: nil)
            }
        })
    }
    
    func stop() {
        if let t = self.task {
            // Kill entire process group to also terminate any orphaned children.
            killpg(getpgid(t.processIdentifier), SIGTERM)
            t.waitUntilExit()
        }
        self.task = nil
    }
    
    func stopForQuit() {
        // Called only when app is quitting.
        // Kill the process group directly without posting KCPTUN_STOP
        // so KcpProxyOn stays true for next auto-start.
        isQuitting = true
        if let t = self.task {
            killpg(getpgid(t.processIdentifier), SIGTERM)
        }
        self.task = nil
    }
}

