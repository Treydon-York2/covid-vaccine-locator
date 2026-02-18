//
//  SceneDelegate.swift
//  WC Vax
//
//  Created by Treydon York on 4/25/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // IMPORTANT: Force programmatic setup (no storyboard)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window programmatically
        let window = UIWindow(windowScene: windowScene)
        
        // Create view controller programmatically
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        // Set as root and show
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // Store reference
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

