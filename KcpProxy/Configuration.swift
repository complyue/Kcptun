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
let KCPTUN_START = Notification.Name("KCPTUN_START")
let KCPTUN_STOP = Notification.Name("KCPTUN_STOP")
let USERDEFAULTS_KCPTUN_ON = "KcpProxyOn"
let USERDEFAULTS_PROFILE = "Profile"

// Tinyproxy Helper
let TINYPROXY_START = Notification.Name("TINYPROXY_START")
let TINYPROXY_STOP = Notification.Name("TINYPROXY_STOP")
let TINYPROXY_CONF_DIR = "/tmp/tinyproxy"

// Version Checker Helper
let _VERSION_XML_URL = "https://raw.githubusercontent.com/paradiseduo/KcpProxy/master/KcpProxy/Info.plist"
let _VERSION_XML_LOCAL:String = Bundle.main.bundlePath + "/Contents/Info.plist"

// Log Helper
let LOG_PATH = "/usr/local/var/log/kcptun"
let LOG_CLEAN_FINISH = Notification.Name("LOG_CLEAN_FINISH")

// Launcher Helper
let USERDEFAULTS_LAUNCH_AT_LOGIN = "USERDEFAULTS_LAUNCH_AT_LOGIN"
let KILL_LAUNCHER = Notification.Name("MacOS_KcpProxy_KILL_LAUNCHER")
let LAUNCHER_APPID = "MacOS.KcpProxy.StartAtLoginLauncher"

let ISSUES_URL = "https://github.com/paradiseduo/KcpProxy/issues"
let RELEASE_URL = "https://github.com/paradiseduo/KcpProxy/releases"
