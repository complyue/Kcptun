//
//  ProxyManager.swift
//  KcpProxy
//
//  Created by Fullstack Developer on 2025/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class ProxyManager {
    let binary = Bundle.main.path(forResource: "3proxy", ofType: nil)
    static let shared = ProxyManager()
    private var task: Process?
    private var logFileHandle: FileHandle?
    private var confPath: String {
        return "\(PROXY_CONF_DIR)/3proxy.conf"
    }
    private var logPath: String {
        return "\(PROXY_CONF_DIR)/3proxy.log"
    }
    
    func start() {
        if let t = self.task, t.isRunning {
            return
        }
        
        writeConfFile()
        
        guard let bin = self.binary else {
            print("ProxyManager: binary not found in bundle")
            return
        }
        
        if !FileManager.default.fileExists(atPath: bin) {
            print("ProxyManager: 3proxy binary does not exist")
            return
        }
        
        createLogFile()
        
        self.task = Process()
        CommandLine.async(task: self.task!, shellPath: bin, arguments: [confPath], output: { output in
            let msg = "3proxy: \(output)"
            print(msg)
            self.writeToLog(msg)
        }, terminate: { status in
            let msg = "3proxy stopped (exit code: \(status))"
            print(msg)
            self.writeToLog(msg)
        })
        
        NotificationCenter.default.post(name: PROXY_START, object: nil)
    }
    
    func stop() {
        if let t = self.task {
            t.terminate()
            t.waitUntilExit()
        }
        self.task = nil
        closeLogFile()
        NotificationCenter.default.post(name: PROXY_STOP, object: nil)
    }
    
    private func writeConfFile() {
        let conf = Profile.shared.proxyConf()
        do {
            try FileManager.default.createDirectory(
                atPath: PROXY_CONF_DIR,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try conf.write(toFile: confPath, atomically: true, encoding: .utf8)
        } catch {
            let msg = "ProxyManager: failed to write conf: \(error)"
            print(msg)
            writeToLog(msg)
        }
    }
    
    private func createLogFile() {
        do {
            try FileManager.default.createDirectory(
                atPath: PROXY_CONF_DIR,
                withIntermediateDirectories: true,
                attributes: nil
            )
            if FileManager.default.fileExists(atPath: logPath) {
                try FileManager.default.removeItem(atPath: logPath)
            }
            FileManager.default.createFile(atPath: logPath, contents: nil, attributes: nil)
            logFileHandle = FileHandle(forWritingAtPath: logPath)
        } catch {
            print("ProxyManager: failed to create log file: \(error)")
        }
    }
    
    private func closeLogFile() {
        logFileHandle?.closeFile()
        logFileHandle = nil
    }
    
    private func writeToLog(_ message: String) {
        if let handle = logFileHandle {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            let logLine = "[\(timestamp)] \(message)\n"
            if let data = logLine.data(using: .utf8) {
                handle.write(data)
                handle.synchronizeFile()
            }
        }
    }
}
