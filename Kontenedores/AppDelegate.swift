//
//  AppDelegate.swift
//  Kontenedores
//
//  Created by Admin on 19/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {

    static let instanciaCompartida = AppDelegate()

    static var fcmToken : String = "123124124twfereferfergerfwedwqd3rf"
    
    static var permitirNotificaciones : Bool = true
    static var pushConfirmacionPedido : Bool = false
    static var listaPedido = [Any]()
    
    //static var idCompra = 0
    
    //static var montoCompra : Double = 0
    
    var usuario:Usuario?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
                
                AppDelegate.permitirNotificaciones = granted
            }
            
        } else {
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("FCM : Messaging Hemos recibido el Token Registrado : \(fcmToken)")
        AppDelegate.fcmToken = fcmToken
        //print("Ahora el fcm Token es", self.fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("FCM : Recibimos un mensaje .MessagingRemoteMessage")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //print("APN Will Present Notification: ",notification.request.content.userInfo)
        completionHandler([.alert,.sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Did Receive response ",response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        //let aps =  userInfo[AnyHashable("aps")] as? NSDictionary
        //let alerta = aps?["alert"] as? [String:Any]
        //let msj = alerta?["body"] as! String
        
        guard let montoStr =  userInfo[AnyHashable("monto")] as? String,  let idCompraStr = userInfo[AnyHashable("compra_id")] as? String else {return}
        
        print("El monstoStr es \(montoStr) y la compra_id es \(idCompraStr)")
        
        AppDelegate.listaPedido.removeAll()
        
        let lista : [Any] = [Int(idCompraStr)!,Double(montoStr)!]
        AppDelegate.listaPedido = lista
//        print(lista.first as? Int ?? 0)
//        print(lista.last as? Double ?? 0)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ListaPedidos"), object: nil)
        
        completionHandler()
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        print("Device Token Apns :\(Messaging.messaging().apnsToken)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

