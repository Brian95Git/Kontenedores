//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        
        guard let topViewController : UIViewController = self.navigationController?.topViewController else {return}
        
        print("View Controller is : \(topViewController) \n", terminator: "")
        
        let usuario = AppDelegate.instanciaCompartida.usuario
        let tipoUsuario = usuario?.tipo ?? "cliente"
        
        switch(index){
        case 0:
//            print("Home\n", terminator: "")
            var id = ""
            switch tipoUsuario
            {
            case "cliente":
                id =  "PagarVC"
            case "proveedor":
                id = "HistorialPedidosVC"
            case "escaner":
                id = "EntradaScanVC"
            default:
                break
            }
            self.openViewControllerBasedOnIdentifier(id)
            break
        case 1:
            print("Vamos a la pantalla Saldo")
            var id = ""
            
            switch tipoUsuario
            {
            case "cliente":
                id =  "ObrasVC"
            case "proveedor":
                id = "CategoriasVC"
            case "escaner":
                id = "ControlObrasVC"
            default:
                break
            }
            
            self.openViewControllerBasedOnIdentifier(id)
        case 2:
//            print("Vamos a la pantalla Obras")
            var id = ""
            
            switch tipoUsuario
            {
            case "cliente":
                id = "SaldoVC"
            case "proveedor":
                id = "ProviderPerfilVC"
            default:
                break
            }
            
            self.openViewControllerBasedOnIdentifier(id)
            break
        case 3:
//            print("Vamos a la pantalla Mis Entradas")
            self.openViewControllerBasedOnIdentifier("MisEntradasVC")
        case 4:
//            print("Vamos a la pantalla Historial")
            self.openViewControllerBasedOnIdentifier("HistorialVC")
            break
        case 5:
//            print("Vamos a la pantalla Perfil")
            self.openViewControllerBasedOnIdentifier("PerfilVC")
            break
        default:
            print("default\n", terminator: "")
        }
        
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
//        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
//        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControl.State())
//        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
//        
//        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
//        self.navigationItem.leftBarButtonItem = customBarItem;
        
        (self.view.viewWithTag(56) as! UIButton).setImage(self.defaultMenuImage(), for: .normal)
        (self.view.viewWithTag(56) as! UIButton).addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)) , for: .touchUpInside)
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 26), false, 0.0)
        
//        UIColor.black.setFill()
//        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
//        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
//        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 3)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 3)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 3)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
    
        let menuVC : MenuViewController =  self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
