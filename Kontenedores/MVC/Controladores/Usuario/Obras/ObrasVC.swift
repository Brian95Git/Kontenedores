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
    @IBOutlet weak var btnAtras: UIButton!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var activityObras: UIActivityIndicatorView!
    
    let obrasImg :[UIImage]? = [#imageLiteral(resourceName: "obra1"),#imageLiteral(resourceName: "obra2"),#imageLiteral(resourceName: "obra3"),#imageLiteral(resourceName: "obra4")]
    
    var obras : [Obra] = []
    
    var indiceObraActual = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addSlideMenuButton()
        
        obrasCV.dataSource = self
        obrasCV.delegate = self
        
        self.obtenerObras()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pintarSaldoUsuario()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let miSaldo = AppDelegate.instanciaCompartida.usuario,miSaldo.saldo <= 0
        {
            let alertController = UIAlertController(title: "Kontenedores", message: "No tienes saldo.Por favor,recárgalo en la pantalla Recargar Saldo.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                self.performSegue(withIdentifier: "recargarSaldo", sender: self)
                
            }
            let ahoraNo = UIAlertAction(title: "Ahora no", style: .default, handler: nil)
            
            alertController.addAction(ok)
            alertController.addAction(ahoraNo)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        if !AppDelegate.permitirNotificaciones
        {
            let alertController = UIAlertController(title: "Kontenedores", message: "No podrás realizar compras de productos o servicios si niegas el envio de notificaciones.Por favor,permitelas en la configuración del dispositivo.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)

            alertController.addAction(ok)

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Pintar Saldo
    
    func pintarSaldoUsuario()
    {
        if let usuario = AppDelegate.instanciaCompartida.usuario
        {
            self.saldoLabel.text = "S/. \(usuario.saldo.valorNumerico2DecimalesStr())"
        }else
        {
            self.saldoLabel.text = "0.00"
        }
    }
    
    // MARK: Obtener Obras
    
    func obtenerObras()
    {
        self.obras.removeAll()
        self.activityObras.startAnimating()
        
        KontenedoreServices.instancia.obtenerObras(todasLasObras: false) { (respuesta) in
            
            if let obras = respuesta as? [Obra]
            {
                self.obras = obras
                self.obrasCV.reloadData()
                self.activityObras.stopAnimating()
            }
        }
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
        
        let etiqueta = self.obras[indexPath.row].etiqueta == "primetime"
        
        celda.backgroundColor = (etiqueta) ? UIColor.white : #colorLiteral(red: 0.8294701938, green: 0.7245562089, blue: 0.8951218501, alpha: 1)
        /*if  indexPath.row < obrasImg?.count ?? 0
        {
            portada.image = obrasImg?[indexPath.row]
        }else
        {
            portada.image = #imageLiteral(resourceName: "portadaObraPlaceHolder")
        }*/
       
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //self.indiceObraActual = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let anchura = UIScreen.main.bounds.width
        //let altura = obrasCV.bounds.height
        return CGSize(width: anchura / 2, height: 250)
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
            
//            if  indiceObra.row < obrasImg?.count ?? 0
//            {
//                detalleObra.imgObraSelect  = (obrasImg?[indiceObra.row])!
//            }else
//            {
//                detalleObra.imgObraSelect  = #imageLiteral(resourceName: "portadaObraPlaceHolder")
//            }
        }
        
        if segue.identifier == "volverRecargarSaldo"
        {
            
        }
        
    }
}
