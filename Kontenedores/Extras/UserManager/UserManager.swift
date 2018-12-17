//
//  UserManager.swift
//  Snoop
//
//  Created by Javier  Siancas on 9/02/17.
//  Copyright © 2017 Fernando Daniel Mateo Ramos. All rights reserved.
//



/*************************************** VERSIONAMIENTO ***************************************/
//  Versión 1.0.0:
//  1. Se creó el archivo.
//  2. Se crearon los siguientes métodos:
//  - saveUserLogged:additionalImplementation:
//  - userLogged:
//  - deleteUser:additionalImplementation:
/**********************************************************************************************/



import UIKit

/// El nombre de la llave para guardar el usuario usando `NSUserDefaults`.
private let UserDataKey = "UserDataKey"
private let VeterinaryDataKey = "VeterinaryDataKey"




/**
 Clase que maneja la persistencia de los usuarios de la aplicación.
 Esta clase expone métodos que permiten guardar al usuario que ha iniciado sesión, obtenerlo en el momento que la aplicación lo necesite y eliminarlo cuando se cierre la sesión.
 */
internal class UserManager: NSObject {

    // MARK: - UserManager's methods
    
    /**
     Método para guardar al usuario que ha iniciado sesión.
     - Parameters:
        - user: El usuario que ha iniciado sesión y que desea guardar en la aplicación.
        - additionalImplementation: Bloque de código opcional para ejecutar después de guardar al usuario.
     - Returns: Valor que permite saber si el usuario fue guardado exitosamente o no.
     */
    internal class func saveUserLogged(_ user: Any?, _ additionalImplementation: (() -> Void)?) -> Bool {
        var userDataSaved = false
//        print("Guardando Usuario")
        if user != nil {
//            print("Guardo Usuario")
            // Eliminar un usuario que ha iniciado sesión previamente.
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: UserDataKey)
            
            // Guardar al nuevo usuario.
            //let userData = NSKeyedArchiver.archivedData(withRootObject: user!)
            do
            {
                let userData = try NSKeyedArchiver.archivedData(withRootObject: user!, requiringSecureCoding: false)
                userDefaults.set(userData, forKey: UserDataKey)
                userDataSaved = userDefaults.synchronize()
            }catch let error
            {
                print("Error Saved User",error.localizedDescription)
            }
  
            
            // Ejecutar bloque de código adicional después de guardar al usuario.
            additionalImplementation?()
        }
        
        return userDataSaved
    }
    
//    //Guardar la Veterinaria
//    internal class func saveVeterinarySelected(_ veterinary: Any?, _ additionalImplementation: (() -> Void)?) -> Bool {
//        var veterinaryDataSaved = false
//
//        if veterinary != nil {
//            // Eliminar un usuario que ha iniciado sesión previamente.
//            let userDefaults = UserDefaults.standard
//            userDefaults.removeObject(forKey: VeterinaryDataKey)
//
//            // Guardar la nueva veterinaria.
//            let veterinaryData = NSKeyedArchiver.archivedData(withRootObject: veterinary!)
//            userDefaults.set(veterinaryData, forKey: VeterinaryDataKey)
//            veterinaryDataSaved = userDefaults.synchronize()
//
//            // Ejecutar bloque de código adicional después de guardar al usuario.
//            additionalImplementation?()
//        }
//
//        return veterinaryDataSaved
//    }
    
    /**
     Método para retornar el usuario que ha iniciado sesión.
     - Returns: El usuario que ha iniciado sesión o `nil` si no existe.
     */
    internal class func userLogged() -> Any? {
        var userLogged: Any?
        
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: UserDataKey) as? Data
        if data != nil { /* Si hay un `NSData` que represente al usuario, entonces... */
            //userLogged = NSKeyedUnarchiver.unarchiveObject(with: data!)
            do
            {
                userLogged = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data!)
            }catch let error
            {
                print("Error User Logged",error.localizedDescription)
            }
            
        }
        
        return userLogged
    }
    
//    /**
//     Método para retornar la veterinaria que has elegido.
//     - Returns: La veterinaria que has escogido o `nil` si no existe.
//     */
//    internal class func veterinarySelected() -> Any? {
//        var veterinaryLogged: Any?
//
//        let userDefaults = UserDefaults.standard
//        let data = userDefaults.object(forKey: VeterinaryDataKey) as? Data
//        if data != nil { /* Si hay un `NSData` que represente al usuario, entonces... */
//            veterinaryLogged = NSKeyedUnarchiver.unarchiveObject(with: data!)
//        }
//
//        return veterinaryLogged
//    }
    
    /**
    
     Método para eliminar al usuario que ha iniciado sesión.
     - Parameter additionalImplementation: Bloque de código opcional para ejecutar después de eliminar al usuario.
     - Returns: Valor que permite saber si el usuario fue eliminado exitosamente o no.
     */
    
    internal class func deleteUserLogged(_ additionalImplementation: (() -> Void)?) -> Bool {
        var userDeleted = false
        
        // Eliminar al usuario que ha iniciado sesión.
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: UserDataKey)
        userDeleted = userDefaults.synchronize()
        
        // Ejecutar bloque de código adicional después de eliminar al usuario.
        additionalImplementation?()
        
        return userDeleted
    }
    
    /**
     Método para eliminar a la veterinaria que has seleccionado (aunque no creo que vaya a usar esta opcion,ah no, si lo hare : cuando el usuario se desloguee).
     - Parameter additionalImplementation: Bloque de código opcional para ejecutar después de eliminar a la veterinaria.
     - Returns: Valor que permite saber si la veterinaria fue eliminado exitosamente o no.
     */
    internal class func deleteVeterinarySelected(_ additionalImplementation: (() -> Void)?) -> Bool {
        var veterinaryDeleted = false
        
        // Eliminar al usuario que ha iniciado sesión.
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: VeterinaryDataKey)
        veterinaryDeleted = userDefaults.synchronize()
        
        // Ejecutar bloque de código adicional después de eliminar al usuario.
        additionalImplementation?()

        return veterinaryDeleted
    }
}
