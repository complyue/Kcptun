//
//  TinyproxyManager.swift
//  KcpProxy
//
//  Created by Fullstack Developer on 2025/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class TinyproxyManager {
    let binary = Bundle.main.path(forResource: "tinyproxy", ofType: nil)
    static let shared = TinyproxyManager()
    private var task: Process?
    private var confPath: String {
        return "\(TINYPROXY_CONF_DIR)/tinyproxy.conf"
    }
    
    func start() {
        if let t = self.task, t.isRunning {
            return
        }
        
        // Write config file from Profile settings
        writeConfFile()
        
        guard let bin = self.binary else {
            print("TinyproxyManager: binary not found in bundle")
            return
        }
        
        self.task = Process()
        CommandLine.async(task: self.task!, shellPath: bin, arguments: ["-d", "-c", confPath], output: { output in
            print("Tinyproxy: \(output)")
        }, terminate: { _ in
            print("Tinyproxy stopped")
        })
        
        NotificationCenter.default.post(name: TINYPROXY_START, object: nil)
    }
    
    func stop() {
        if let t = self.task {
            t.terminate()
            t.waitUntilExit()
        }
        self.task = nil
        NotificationCenter.default.post(name: TINYPROXY_STOP, object: nil)
    }
    
    private func writeConfFile() {
        let conf = Profile.shared.tinyproxyConf()
        do {
            try FileManager.default.createDirectory(
                atPath: TINYPROXY_CONF_DIR,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try conf.write(toFile: confPath, atomically: true, encoding: .utf8)
        } catch {
            print("TinyproxyManager: failed to write conf: \(error)")
        }
    }
}
