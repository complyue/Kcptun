//
//  Launch.swift
//  Kcptun
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class Kcptun {
    let kcptun = Bundle.main.path(forResource: "client_darwin_amd64", ofType: nil)
    static let shared = Kcptun()
    private var task: Process?
    // When true, the KCPTUN_STOP notification will NOT update KcptunOn.
    // Used when app is quitting so KcptunOn persists for next auto-start.
    private var isQuitting = false
    
    func start() {
        if let t = self.task, t.isRunning {
            return
        }
        self.task = Process()
        CommandLine.async(task: self.task!, shellPath: self.kcptun!, arguments: Profile.shared.arguments(), terminate:  { (finish) in
            print("Kcptun turn off!")
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
        // so KcptunOn stays true for next auto-start.
        isQuitting = true
        if let t = self.task {
            killpg(getpgid(t.processIdentifier), SIGTERM)
        }
        self.task = nil
    }
}

