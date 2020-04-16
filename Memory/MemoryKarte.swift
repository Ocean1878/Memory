//
//  MemoryKarte.swift
//  Memory
//
//  Created by Iman Kefayati on 11.04.20.
//  Copyright © 2020 Iman Kefayati. All rights reserved.
//

import Cocoa

// Die Klasse für eine Karte des Memory-Spiels
// Sie erbt von NSButton
class MemoryKarte: NSButton {

    // die Eigenschaften
    // eine eindeutige ID zur Identifizierung des Bildes
    var bildID: Int!
    
    // für die Vorder- und Rückseite
    var bildVorne, bildHinten: NSImage!
    
    // wo liegt die Karte im Spielfeld?
    var bildPos: Int!
    
    // ist die Karte umgedreht?
    var umgedreht: Bool!
    
    // ist die Karte noch im Spiel?
    var nochImSpiel: Bool!
    
    // für das Spielfeld
    var spiel: ViewController!
    
    // der Initialisierer
    // er setzt die Größe, die Bilder und die Position
    init(vorne: String, bildID: Int, position: CGRect, spiel: ViewController) {
        // den Initialisierer der Basisklasse aufrufen
        // dabei wird die Position weitergereicht
        super.init(frame: position)
        // die Vorderseite, der Name des Bildes wird an den
        // Initialisierer übergeben
        bildVorne = NSImage(named: vorne)
        // die Größe setzen
        bildVorne.size = NSSize(width: 64, height: 64)
        
        // die Rückseite, sie wird fest gesetzt
        bildHinten = NSImage(named: "verdeckt")
        // die Größe setzen
        bildHinten.size = NSSize(width: 64, height: 64)
        
        // die Eigenschaften zuweisen
        // das Bild
        self.image = bildHinten
        // die Bild-ID
        self.bildID = bildID
        // die Karte ist erst einmal umgedreht und noch im Feld
        umgedreht = false
        nochImSpiel = true
        
        // mit dem Spielfeld verbinden
        self.spiel = spiel
        
        // die Action ergänzen
        // erst das Ziel
        self.target = self
        // dann die Methode
        self.action = #selector(buttonClicked)
    }
    
    // der Initialisierer wird durch die Basisklasse erzwungen
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // der andere Initialisierer ruft den entsprechenden
    // Initialisierer der Basisklasse auf
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // die Methode für das Anklicken
    @objc func buttonClicked() {
        // ist die Karte überhaupt noch im Spiel?
        if nochImSpiel == false || spiel.zugErlaubt() == false {
            return
        }
        
        // wenn die Rückseite zu sehen ist, die Vorderseite anzeigen
        if umgedreht == false {
            vorderseiteZeigen()
            
            // die Methode karteOeffnen() im ViewController aufrufen
            // übergeben wird dabei die Karte - also self
            spiel.karteOeffnen(karte: self)
        }
    }
    
    // die Methode zeigt die Rückseite der Karte an
    func rueckseiteZeigen(rausnehmen: Bool) {
        // soll die Karten komplett aus dem Spiel genommen werden?
        if rausnehmen == true {
            // das Bild aufgedeckt zeigen und die Karte aus dem Spiel
            // nehmen
            self.image = NSImage(named: "aufgedeckt")
            self.image?.size = NSSize(width: 64, height: 64)
            nochImSpiel = false
        } else {
            // sonst nur die Rückseite zeigen
            self.image = bildHinten
            umgedreht = false
        }
    }
    
    // die Methode zeigt die Vorderseite der Karte an
    func vorderseiteZeigen() {
        self.image = bildVorne
        umgedreht = true
    }
    
    // die Methode liefert die Bild-ID einer Karte
    func getBildID() -> Int {
        return bildID
    }
    
    // die Methode liefert die Position einer Karte
    func getBildPos() -> Int {
        return bildPos
    }
    
    // die Methode liefert die Position einer Karte
    func setBildPos(bildPos: Int) {
        self.bildPos = bildPos
    }
    
    // die Methode leifert den Wert der Eigenschaft umgedreht
    func getUmgedreht() -> Bool {
        return umgedreht
    }
    
    // die Methode liefert den Wert der Eigenschaft nochImSpiel
    func getNochImSpiel() -> Bool {
        return nochImSpiel
    }
}
