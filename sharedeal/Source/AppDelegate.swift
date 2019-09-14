//
//  AppDelegate.swift
//  sharedeal
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        startApp()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func startApp() {
        guard let sellingVC = R.storyboard.main.instantiateInitialViewController() else {
            fatalError("Expected to find initial viewcontroller in storyboard")
        }
        
        let coordinator = ShareSellingListCoordinatorImpl()
        let provider = getProvider()
        let repo = ShareSellingRepositoryImpl(provider: provider)
        sellingVC.viewModel = ShareSellingListViewModel(provider: provider,
                                                        coordinator: coordinator,
                                                        repo: repo)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = sellingVC
        self.window?.makeKeyAndVisible()
    }
    
    private func getProvider() -> ServiceProvider {
        // TODO: Use https instead of http
        // TODO: Move this elsewhere
        let environment = Environment(name: "Production", host: "http://developerexam.equityplansdemo.com")
        return ServiceProviderImpl(environment: environment)
        
    }
}
