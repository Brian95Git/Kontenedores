//
//  MesTBVC.swift
//  PushNotificacionTest
//
//  Created by Admin on 2/11/18.
//  Copyright © 2018 Area51. All rights reserved.
//

import UIKit

class MesTBVC: UITableViewController {

    var listaNumeros : [String] = []
    
    var tagBtn  = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listaNumeros.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tarjetaVC = self.popoverPresentationController?.delegate as! TarjetaVC
        
        dismiss(animated: true) {
            let cell = tableView.cellForRow(at: indexPath)!
            let mmaaamonto = cell.contentView.subviews.first! as! UILabel
            
            switch self.tagBtn
            {
            case 0:
                tarjetaVC.btnMM.setTitle(mmaaamonto.text!, for: .normal)
            case 1:
                tarjetaVC.btnAAAA.setTitle(mmaaamonto.text!, for: .normal)
            case 2:
                tarjetaVC.btnMonto.setTitle(mmaaamonto.text!+".00", for: .normal)
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mmAAAAMonto", for: indexPath)

        // Configure the cell...
        let txtMonto = cell.contentView.subviews.first! as! UILabel
        txtMonto.text = listaNumeros[indexPath.row]
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
     
    }
    */

}
