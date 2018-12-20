//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    @IBOutlet weak var btnSmallCloseMenuOverlay: UIButton!
    
 
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
    
    let userOptions = ["Pagar","Ver Obras","Mis Recargas","Mis Entradas","Mis Compras","Perfil","Salir"]
    
    let providerOptions = ["Lista Pedidos","Categorias","Perfil","Salir"]
    
    let escanerOptions = ["Escanear","Ver Obras","Salir"]
    
    var menuOptionSelect : [String] = []

    var usuario : Usuario!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tblMenuOptions.clipsToBounds = false
        tblMenuOptions.layer.shadowOpacity = 0.5
        tblMenuOptions.layer.shadowRadius = 12
        
        //tblMenuOptions.tableFooterView = UIView()
       
        usuario = AppDelegate.instanciaCompartida.usuario!
        
        switch usuario.tipo {
        case "cliente" :
            menuOptionSelect = userOptions
        case "proveedor":
            menuOptionSelect = providerOptions
        case "escaner":
            menuOptionSelect = escanerOptions
        default:
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":"Home", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"Play", "icon":"PlayIcon"])
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay || button == self.btnSmallCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParent()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuOptionSelect.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let activity = cell.contentView.viewWithTag(104) as! UIActivityIndicatorView
        
        //imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        //lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        if usuario.tipo == "cliente"
        {
            switch indexPath.row {
            case 0:
                lblTitle.textColor = UIColor.black
                imgIcon.image = self.usuarioCodigoQR()
            default:
                
                lblTitle.textColor = (indexPath.row == 1) ? UIColor.black : UIColor.gray
                
                imgIcon.constraints.first { (constraint) -> Bool in
                    constraint.identifier == "anchuraImg"
                    }?.constant = 0
                break
            }
        }
        
        if indexPath.row == menuOptionSelect.count - 1
        {
            activity.hidesWhenStopped = true
            activity.stopAnimating()
        }else
        {
            activity.isHidden = true
        }
        
        lblTitle.text = menuOptionSelect[indexPath.row]
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.tag = indexPath.row
        
        if indexPath.row == menuOptionSelect.count - 1
        {
            print("Tocamos la ultima celda")
            //self.tblMenuOptions.isUserInteractionEnabled = false
            //activity.hidesWhenStopped = true
            let cell : UITableViewCell = tableView.cellForRow(at: indexPath)!
            let activity = cell.contentView.viewWithTag(104) as! UIActivityIndicatorView
            
            activity.startAnimating()
            
            let tokenUsuario = AppDelegate.instanciaCompartida.usuario?.token

            KontenedoreServices.instancia.cerrarSesion(tokenUsuario: tokenUsuario!) { (respuesta) in
                _ = UserManager.deleteUserLogged(nil)
                self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            }
            
        }else
        {
            self.onCloseMenuClick(btn)
        }
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let esCliente :
            CGFloat = (usuario.tipo == "cliente") ? ((indexPath.row == 0) ? 100 : 60) : 60
        return esCliente
    }
    
    func usuarioCodigoQR() -> UIImage
    {
        let filterQR = CIFilter(name: "CIQRCodeGenerator")!
        
        let id = AppDelegate.instanciaCompartida.usuario?.id
        
        let infoEntrada = String(id!)
        
        let dataEntrada = infoEntrada.data(using: .ascii, allowLossyConversion: false)
        
        filterQR.setValue(dataEntrada, forKey: "inputMessage")
        
        let scalarImgQR = CGAffineTransform(scaleX: 3, y: 3)
        let imgQR = UIImage(ciImage: filterQR.outputImage!.transformed(by: scalarImgQR))
        
        return imgQR
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}
