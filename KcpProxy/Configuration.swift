//
//  Configuration.swift
//  KcpProxy
//
//  Created by ParadiseDuo on 2020/4/2.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

// KcpProxy Helper
let KCPROXY_START = Notification.Name("KCPROXY_START")
let KCPROXY_STOP = Notification.Name("KCPROXY_STOP")
let USERDEFAULTS_KCPROXY_ON = "KcpProxyOn"
let USERDEFAULTS_PROFILE = "Profile"

// 3proxy Helper
let PROXY_START = Notification.Name("PROXY_START")
let PROXY_STOP = Notification.Name("PROXY_STOP")
let PROXY_CONF_DIR = "/tmp/3proxy"

// Version Checker Helper
let _VERSION_XML_URL = "https://raw.githubusercontent.com/paradiseduo/KcpProxy/master/KcpProxy/Info.plist"
let _VERSION_XML_LOCAL:String = Bundle.main.bundlePath + "/Contents/Info.plist"

// Log Helper
let LOG_PATH = "/tmp/kcpproxy"
let LOG_CLEAN_FINISH = Notification.Name("LOG_CLEAN_FINISH")

// Launcher Helper
let USERDEFAULTS_LAUNCH_AT_LOGIN = "USERDEFAULTS_LAUNCH_AT_LOGIN"
let KILL_LAUNCHER = Notification.Name("MacOS_KcpProxy_KILL_LAUNCHER")
let LAUNCHER_APPID = "MacOS.KcpProxy.StartAtLoginLauncher"

let ISSUES_URL = "https://github.com/paradiseduo/KcpProxy/issues"
let RELEASE_URL = "https://github.com/paradiseduo/KcpProxy/releases"
