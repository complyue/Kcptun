//
//  Profile.swift
//  KcpProxy
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 MacClient. All rights reserved.
//

import Foundation

class Profile {
    
    static let shared = Profile()
    
    var host: String = "127.0.0.1"
    var remotePort: Int = 29900
    var localPort: Int = 1087
    var crypt: String = "aes"
    var key: String = "password"
    var mode: String = "fast"
    var mtu: Int = 1350
    var sndwnd: Int = 512
    var rcvwnd: Int = 512
    var datashard: Int = 10
    var parityshard: Int = 3
    var dscp: Int = 0
    var nocomp: Bool = true
    
    // Tinyproxy local HTTP proxy settings
    var tinyproxyPort: Int = 9876
    var tinyproxyUsername: String = ""
    var tinyproxyPassword: String = ""
    
    var json: [String: AnyObject] {
        get {
            let conf:[String: AnyObject] = ["host": "\(self.host)" as AnyObject,
                                            "localPort": NSNumber(value: self.localPort) as AnyObject,
                                            "remotePort": NSNumber(value: self.remotePort) as AnyObject,
                                            "key": self.key as AnyObject,
                                            "crypt": self.crypt as AnyObject,
                                            "mode": self.mode as AnyObject,
                                            "mtu": NSNumber(value: self.mtu) as AnyObject,
                                            "sndwnd": NSNumber(value: self.sndwnd) as AnyObject,
                                            "rcvwnd": NSNumber(value: self.rcvwnd) as AnyObject,
                                            "datashard": NSNumber(value: self.datashard) as AnyObject,
                                            "parityshard": NSNumber(value: self.parityshard) as AnyObject,
                                            "dscp": NSNumber(value: self.dscp) as AnyObject,
                                            "nocomp": NSNumber(value: self.nocomp) as AnyObject,
                                            "tinyproxyPort": NSNumber(value: self.tinyproxyPort) as AnyObject,
                                            "tinyproxyUsername": self.tinyproxyUsername as AnyObject,
                                            "tinyproxyPassword": self.tinyproxyPassword as AnyObject
                                            ]
            return conf
        }
    }
    
    public func saveProfile() {
        let user = UserDefaults.standard
        user.setValue(self.json, forKey: USERDEFAULTS_PROFILE)
        user.synchronize()
        KcpProxy.shared.stop()
        TinyproxyManager.shared.stop()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            KcpProxy.shared.start()
            TinyproxyManager.shared.start()
        }
    }
    
    public func loadProfile() {
        if let p = UserDefaults.standard.value(forKey: USERDEFAULTS_PROFILE) as? [String: AnyObject] {
            self.host = (p["host"] as? String) ?? "127.0.0.1"
            self.remotePort = (p["remotePort"] as? NSNumber)?.intValue ?? 29900
            self.localPort = (p["localPort"] as? NSNumber)?.intValue ?? 1087
            self.key = (p["key"] as? String) ?? "password"
            self.crypt = (p["crypt"] as? String) ?? "aes"
            self.mode = (p["mode"] as? String) ?? "fast"
            self.mtu = (p["mtu"] as? NSNumber)?.intValue ?? 1350
            self.sndwnd = (p["sndwnd"] as? NSNumber)?.intValue ?? 512
            self.rcvwnd = (p["rcvwnd"] as? NSNumber)?.intValue ?? 512
            self.datashard = (p["datashard"] as? NSNumber)?.intValue ?? 10
            self.parityshard = (p["parityshard"] as? NSNumber)?.intValue ?? 3
            self.dscp = (p["dscp"] as? NSNumber)?.intValue ?? 0
            self.nocomp = (p["nocomp"] as? NSNumber)?.boolValue ?? true
            self.tinyproxyPort = (p["tinyproxyPort"] as? NSNumber)?.intValue ?? 9876
            self.tinyproxyUsername = (p["tinyproxyUsername"] as? String) ?? ""
            self.tinyproxyPassword = (p["tinyproxyPassword"] as? String) ?? ""
        }
    }
    
    func arguments() -> [String] {
        if self.nocomp {
            return ["-r","\(self.host):\(self.remotePort)",
                "-l",":\(self.localPort)",
                "--mode",self.mode,
                "--crypt",self.crypt,
                "--key",self.key,
                "--mtu","\(self.mtu)",
                "--sndwnd","\(self.sndwnd)",
                "--rcvwnd","\(self.rcvwnd)",
                "--datashard","\(self.datashard)",
                "--dscp","\(self.dscp)",
                "--nocomp",
                "--log",LOG_PATH
            ]
        } else {
            return ["-r","\(self.host):\(self.remotePort)",
                "-l",":\(self.localPort)",
                "--mode",self.mode,
                "--crypt",self.crypt,
                "--key",self.key,
                "--mtu","\(self.mtu)",
                "--sndwnd","\(self.sndwnd)",
                "--rcvwnd","\(self.rcvwnd)",
                "--datashard","\(self.datashard)",
                "--dscp","\(self.dscp)",
                "--log",LOG_PATH
            ]
        }
    }
    
    /// Generate tinyproxy.conf content from current profile settings.
    /// Local listen IP = 127.0.0.1 (localhost)
    /// Upstream proxy = KcpProxy's local port (127.0.0.1:localPort)
    func tinyproxyConf() -> String {
        let listenIP = "127.0.0.1"
        let upstreamProxy = "127.0.0.1:\(self.localPort)"
        
        var lines: [String] = [
            "User nobody",
            "Group nobody",
            "Listen \(listenIP)",
            "Port \(tinyproxyPort)",
            "Timeout 600",
            "MaxClients 100",
            "Allow 127.0.0.1",
            "Allow ::1",
            "LogLevel Info",
        ]
        
        if !tinyproxyUsername.isEmpty && !tinyproxyPassword.isEmpty {
            lines.append("upstream http \(tinyproxyUsername):\(tinyproxyPassword)@\(upstreamProxy)")
        } else {
            lines.append("upstream http \(upstreamProxy)")
        }
        
        return lines.joined(separator: "\n") + "\n"
    }
}
