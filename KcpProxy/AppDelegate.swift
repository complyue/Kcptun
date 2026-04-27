//
//  AppDelegate.swift
//  KcpProxy
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 Mac. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Load saved profile before starting KcpProxy
        Profile.shared.loadProfile()
        
        if UserDefaults.standard.bool(forKey: USERDEFAULTS_KCPROXY_ON) {
            KcpProxy.shared.start()
            ProxyManager.shared.start()
        }
        
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == LAUNCHER_APPID }.isEmpty
        if isRunning {
            DistributedNotificationCenter.default().post(name: KILL_LAUNCHER, object: Bundle.main.bundleIdentifier!)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // No-op: Quit menu (stopForQuit) handles KcpProxy termination.
        // Calling stop() here causes a race with the terminate callback
        // in CommandLine.async, leading to SIGSEGV when accessing self.task.
    }
    
    static func getLauncherStatus() -> Bool {
        return LoginServiceKit.isExistLoginItems()
    }
    
    static func setLauncherStatus(open: Bool) {
        if open {
            LoginServiceKit.addLoginItems()
        } else {
            LoginServiceKit.removeLoginItems()
        }
    }
}
