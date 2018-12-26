//
//  ObrasVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 5/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class ObrasVC: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var obrasCV: UICollectionView!
    @IBOutlet weak var btnSaldo: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var activityObras: UIActivityIndicatorView!
    
    var obras : [Obra] = []
    //var indiceObraActual = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addSlideMenuButton()
        
        obrasCV.dataSource = self
        obrasCV.delegate = self
    
        self.consultarSaldo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(actualizarDataUsuario), name: NSNotification.Name(rawValue: "UsuarioDeslogueado"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        print("will Appear Obras")
        if obras.isEmpty {self.obtenerObras()}
        self.actualizarDataUsuario()
    }
    
    @objc func actualizarDataUsuario()
    {
        self.pintarSaldoUsuario()
        btnMenu.isHidden = (AppDelegate.instanciaCompartida.usuario == nil)
        btnLogin.isHidden = !btnMenu.isHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func consultarSaldo()
    {
        if let miSaldo = AppDelegate.instanciaCompartida.usuario,miSaldo.saldo <= 0,AppDelegate.irRecargarSaldo
        {
            let alertController = UIAlertController(title: "Kontenedores", message: "No tienes saldo.Por favor,recárgalo en la pantalla Recargar Saldo.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                self.performSegue(withIdentifier: "recargarSaldo", sender: self)
                
            }
            let ahoraNo = UIAlertAction(title: "Ahora no", style: .default) { (action) in
                AppDelegate.irRecargarSaldo = false
            }
            
            alertController.addAction(ok)
            alertController.addAction(ahoraNo)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Pintar Saldo
    
    func pintarSaldoUsuario()
    {
        if let usuario = AppDelegate.instanciaCompartida.usuario,usuario.saldo > 0
        {
            self.saldoLabel.text = "S/. \(usuario.saldo.valorNumerico2DecimalesStr())"
        }else
        {
            //AppDelegate.instanciaCompartida.usuario = nil
            self.saldoLabel.text = "S/ 0.00"
        }
    }
    
    // MARK: Obtener Obras
    
    func obtenerObras()
    {
        self.comprobarInternet { (disponible, msj) in
            DispatchQueue.main.async {
                if !disponible
                {
                    self.activityObras.stopAnimating()
                    self.mostrarAlerta(msj: msj)
                }else
                {
                    self.obtenerObrasWS()
                }
            }
        }
    }
    
    func obtenerObrasWS()
    {
        self.activityObras.startAnimating()
        
        KontenedoreServices.instancia.obtenerObras(todasLasObras: false) { (respuesta) in
            
            if let obras = respuesta as? [Obra]
            {
                self.obras.removeAll()
                self.obras = obras
                self.obrasCV.reloadData()
                self.activityObras.stopAnimating()
            }
        }
    }
    
    
    @IBAction func irAlLogin(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    
    // MARK: CollectionView Metodos
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.obras.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "obraCell", for: indexPath) as! ObraCVCell
    
        //let portada = celda.contentView.subviews.first as! UIImageView
        //let titulo = celda.contentView.subviews[1] as! UILabel
        celda.tituloObra.text = self.obras[indexPath.row].titulo
        celda.pintarPortada(obra: self.obras[indexPath.row])
        
        celda.establecerCintillo(obra: self.obras[indexPath.row])
        
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //self.indiceObraActual = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //anchuraPortadaObra : CGFloat = 375 // -> 187.5 -> 100 %
        //alturaPortadaObra : CGFloat = 600  // -> 300 -> 100 % 300 = 187.5 *  1.6
        
        let anchuraPantalla = UIScreen.main.bounds.width
        
        let anchuraCelda = (anchuraPantalla / 2)
    
        let alturaCelda = anchuraCelda * 1.6
        
        return CGSize(width: anchuraCelda, height: alturaCelda)
    }

    //MARK: Cambiar Obra
    
    @IBAction func atrasObra(_ sender: UIButton)
    {
        guard let celdaObra = obrasCV.visibleCells.first else {return}
    
        let indexPathObra = obrasCV.indexPath(for: celdaObra)!
        
        if indexPathObra.row != 0
        {
            let indexPathObraAnterior = IndexPath(row: indexPathObra.row - 1, section: 0)
            self.obrasCV.scrollToItem(at: indexPathObraAnterior, at: .left, animated: true)
        }
        
        //print("ATRAS : El indexPath Obra es \(indexPathObra)")
    }
    
    @IBAction func adelanteObra(_ sender: UIButton)
    {
        guard let celdaObra = obrasCV.visibleCells.first else {return}
        
        let indexPathObra = obrasCV.indexPath(for: celdaObra)!
        
        if indexPathObra.row < self.obras.count - 1
        {
            let indexPathObraSiguiente = IndexPath(row: indexPathObra.row + 1, section: 0)
            self.obrasCV.scrollToItem(at: indexPathObraSiguiente, at: .right, animated: true)
        }
        
        //print("ADELANTE : El indexPath Obra es \(indexPathObra)")
    }
    
    // MARK: Volver Obras
    
    @IBAction func volverObras(segue: UIStoryboardSegue)
    {
        self.obrasCV.isUserInteractionEnabled = true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToDetalleObra"
        {
            let celda = sender as! ObraCVCell
            let detalleObra = segue.destination as! DetalleObraVC
            let indiceObra = obrasCV.indexPath(for: celda)!
            
            detalleObra.obra = self.obras[indiceObra.row]
            detalleObra.imgObraSelect = celda.portadaObra.image!
        }
        
        if segue.identifier == "goToLogin"
        {
            let loginVC = segue.destination as! LoginVC
            loginVC.ocultarBtn = false
        }
        
    }
}
