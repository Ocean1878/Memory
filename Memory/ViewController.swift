//
//  ViewController.swift
//  Memory
//
//  Created by Iman Kefayati on 11.04.20.
//  Copyright © 2020 Iman Kefayati. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var labelPaareMensch: NSTextField!
    
    @IBOutlet weak var labelPaareComputer: NSTextField!
    
    @IBOutlet weak var spielstaerkeAnzeige: NSTextField!
    
    @IBOutlet weak var starkeSlider: NSSlider!
    
    @IBOutlet weak var schummelTaste: NSButton!
    
    
    // MARK: - Eigenschaften
    
    // das Array für die Karten
    var karten = [MemoryKarte]()
    
    // das Array für die Namen der Grafiken
    // bitte in einer Zeile eingeben
    var bilder = ["apfel", "birne", "blume", "blume2", "ente", "fisch", "fuchs", "igel", "kaenguruh", "katze", "kuh", "maus1", "maus2", "maus3", "melone", "pilz", "ronny", "schmetterling", "sonne", "wolke", "maus4"]
    
    // für die Punkte
    var menschPunkte, computerPunkte: Int!
    
    // wie viele Karten sind aktuell umgedreht?
    var umgedrehteKarten: Int!
    
    // für das aktuell umgedrehte Paar
    var paar = [MemoryKarte]()
    
    // für den aktuellen Spieler
    var spieler: Int!
    
    // das "Gedächtnis" für den Computer
    // er speichert hier paarweise, wo das Gegenstück liegt
    var gemerkteKarten = [[Int]]()
    
    //für die Spielstärke
    var spielstaerke = 5
    
    // Timer
    var timer = Timer()
    
    
    // MARK: - Die Methoden
    
    // die Methode zum Initialisieren des Spielfeldes
    func initMeinSpielfeld() {
        // zum Zählen für die Bilder
        var count = 0
//        // zum Positionieren der Karten
//        var spalte = 0
//        var zeile = 1
        
        // keiner hat zu Beginn einen Punkt
        menschPunkte = 0
        computerPunkte = 0
        
        // es ist keine Karte umgedreht
        umgedrehteKarten = 0
        
        // der Mensch fängt an
        spieler = 0
        
        // das Array für die gemerkten Karten aufbauen
        // alle Werte sind -1
        // es gibt also erst einmal keine gemerkten Karten
        for _ in 0 ..< 2 {
            gemerkteKarten.append(Array(repeating: -1, count: 21))
        }
        
        // zwei leere Karten in das Array für die Paare einfügen
        for _ in 0 ..< 2 {
            paar.append(MemoryKarte())
        }
        
        //ein Array mit den Positionsdaten erzeugen
        // und mischen
        var positionen = [Int]()
        for i in 0 ..< 42 {
            positionen.append(i)
            positionen = positionen.shuffled()
        }
        
        // die Positionen mischen
//        for i in 1 ..< positionen.count {
//            var temp1, temp2: Int
//            // eine zufällige Zahl im Bereich 0 bis Länge erzeugen
//            temp1 = Int(arc4random_uniform(UInt32(positionen.count)))
//            // den alten Wert in Sicherheit bringen
//            temp2 = positionen[temp1]
//            // die Werte tauschen
//            positionen[temp1] = positionen[i]
//            positionen[i] = temp2
//        }
        
        
        // das eigentliche Spielfeld erstellen
        for i in 0 ..< 42 {
            // eine neue Karte erzeugen
            // bitte in einer Zeile eingeben
            karten.append(MemoryKarte(vorne: bilder[count], bildID: count, position: CGRect(x: (positionen[i] % 6)  * 64, y: ((positionen[i] / 6) + 1)  * 64, width: 64, height: 64), spiel: self))
            // die Postition der Karte setzen
            karten[i].setBildPos(bildPos: i)
            
            // die Karte hinzufügen
            self.view.addSubview(karten[i])
            
            // bei jeder zweiten Karte kommt auch ein neues Bild
            if (i + 1) % 2 == 0 {
                count = count + 1
            }
        }
//        // die Vorderseiten zeigen
//        for i in 0 ..< 42 {
//            karten[i].buttonClicked()
//        }
    }
    
    // Meldungen
    func meinDialog(header: String, text: String) {
        // den Dialog erzeugen
        let meinDialog: NSAlert = NSAlert()
        // die Texte setzen
        meinDialog.messageText = header
        meinDialog.informativeText = text
        // und anzeigen
        meinDialog.runModal()
    }
    
    // die Methode übernimmt die wesentliche Steuerung des Spiels
    // sie wird beim Anklicken einer Karte ausgeführt
    func karteOeffnen(karte: MemoryKarte) {
        // zum Zwischenspeichern der ID und der Postition
        var kartenID, kartenPos: Int
        // die Karten zwischenspeichern
        paar[umgedrehteKarten] = karte
        
        // die ID und die Position beschaffen
        kartenID = karte.getBildID()
        kartenPos = karte.getBildPos()
        
        // die Karte in das Gedächtnis des Computers eintragen, aber
        // nur dann, wenn es noch keinen Eintrag an der entsprechenden
        // Stelle gibt
        if gemerkteKarten[0] [kartenID] == -1 {
            gemerkteKarten[0] [kartenID] = kartenPos
        } else {
            // wenn es schon einen Eintrag gibt und der nicht mit der
            // aktuellen Postition übereinstimmt, dann habewn wir die
            // zweite Karte gefunden
            // Sie wir in die zweite Dimension eingetragen
            if gemerkteKarten[0] [kartenID] != kartenPos {
                gemerkteKarten[1] [kartenID] = kartenPos
            }
        }
        
        // umgedrehte Karten erhöhen
        umgedrehteKarten = umgedrehteKarten + 1
        
        // sind 2 Karten umgedreht worden?
        if umgedrehteKarten == 2 {
            // dann prüfen wir, ob es ein Paar ist
            paarPruefen(kartenID: kartenID)
            // die Karten wieder umdrehen mit Verzögerung von 2 Sekunden
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(karteSchliessen), userInfo: nil, repeats: false)
        }
        
        // Wenn der Spieler dran ist und bereits eine Karte umgedreht hat
        // wird der Schummeltaste deaktieviert
        if spieler == 0 && umgedrehteKarten == 1 {
            schummelTaste.isEnabled = false
        }
        
        // Meldungen beim Ende des Spiels
        if (menschPunkte > computerPunkte) && (computerPunkte + menschPunkte == 21) {
            // Dialog
            meinDialog(header: "Hinweis", text: "Sie haben Gewonnen \n\nIhr Punktestand: \(labelPaareMensch.integerValue)\n\nPunktestand Gegner: \(labelPaareComputer.integerValue) \n\nDas Spiel ist vorbei!")
            // beenden
            NSApplication.shared.terminate(self)
        } else if (menschPunkte < computerPunkte) && (computerPunkte + menschPunkte == 21) {
            // Dialog
            meinDialog(header: "Hinweis", text: "Sie haben verloren! \n\nPunktestand Gegner: \(labelPaareComputer.integerValue)\n\nIhr Punktestand: \(labelPaareMensch.integerValue) \n\nDas Spiel ist vorbei!")
            // beenden
            NSApplication.shared.terminate(self)
        }
    }
    
    // die Methode prüft, ob ein Paar gefunden wurde
    func paarPruefen(kartenID: Int) {
        if paar[0].getBildID() == paar[1].getBildID() {
            // die Punkte setzen
            paarGefunden()
            // die Karte aus dem Gedächtnis löschen
            gemerkteKarten[0] [kartenID] = -2
            gemerkteKarten[1] [kartenID] = -2
        }
    }
    
    // die Methode setzt die Punkte, wenn ein Paar gefunden wurde
    func paarGefunden() {
        // spielt gerade der Mensch?
        if spieler == 0 {
            menschPunkte = menschPunkte + 1
            labelPaareMensch.integerValue = menschPunkte
        } else {
            computerPunkte = computerPunkte + 1
            labelPaareComputer.integerValue = computerPunkte
        }
    }
    
    // die Methode dreht die Karten wieder auf die Rückseite
    // beziehungsweise nimmt sie aus dem Spiel
    @objc func karteSchliessen() {
        var raus = false
        
        // ist es ein Paar?
        if paar[0].getBildID() == paar[1].getBildID() {
            raus = true
        }
        
        // wenn es ein Paar war, nehmen wir die Karten raus
        paar[0].rueckseiteZeigen(rausnehmen: raus)
        paar[1].rueckseiteZeigen(rausnehmen: raus)
        
        // es ist keine Karte mehr geöffnet
        umgedrehteKarten = 0
        
        // hat der Spieler kein Paar gefunden?
        if raus == false {
            // dann wird der Spieler gewechselt
            spielerWechseln()
        } else {
            // hat der Computer ein Paar gefunden?
            // dann ist er noch einmal an der Reihe
            if spieler == 1 {
                computerZug()
            }
        }
    }
    
    // Spielerwechsel
    func spielerWechseln() {
        // wenn der Mensch an der Reihe war, kommt jetzt der Computer
        // Die Schummeltaste wird jedes mal aktiviert, wenn der Anwender
        // am Zug ist und nicht der Computer
        if spieler == 0 {
            schummelTaste.isEnabled = false
            spieler = 1
            computerZug()
        } else {
            spieler = 0
            schummelTaste.isEnabled = true
        }
    }
    
    // die Methode setzt die Computerzüge um
    // Sie ist erst einmal leer, damit der Compiler nicht mault
    func computerZug() {
        var kartenZaehler = 0
        var zufall = 0
        var treffer = false
        
        // zur Steuerung der Spielstärke
        if Int(arc4random_uniform(UInt32(spielstaerke))) == 0 {
            // erst einmal nach einem Paar suchen
            // dazu durchsuchen wir das Array gemerkteKarten, bis wir in
            // beiden Dimensionen einen Wert für eine Karte finden
            while kartenZaehler < 21 && treffer == false {
                // gibt es in beiden Dimensionen einen Wert größer
                // oder gleich 0?
                // bitte in einer Zeile eingeben
                if gemerkteKarten[0] [kartenZaehler] >= 0 && gemerkteKarten[1] [kartenZaehler] >= 0 {
                    // dann haben wir ein Paar
                    treffer = true
                    
                    // die erste Karte umdrehen durch einen simulierten Klick
                    // auf die Karte
                    // der simulierte Klick wird nicht mehr ausgeführt
                    // karten[gemerkteKarten[0] [kartenZaehler]].performClick(self)
                    // die Vorderseite zeigen
                    // bitte in einer Zeile eingeben
                    karten[gemerkteKarten[0] [kartenZaehler]].vorderseiteZeigen()
                    // und die Karte öffnen
                    karteOeffnen(karte: karten[gemerkteKarten[0] [kartenZaehler]])
                    // die zweite Karte auch
                    // karten[gemerkteKarten[1] [kartenZaehler]].performClick(self)
                    // bitte in einer Zeile eingeben
                    karten[gemerkteKarten[1] [kartenZaehler]].vorderseiteZeigen()
                    // und die Karte öffnen
                    karteOeffnen(karte: karten[gemerkteKarten[1] [kartenZaehler]])
                }
                kartenZaehler = kartenZaehler + 1
            }
        }
        
        // wenn wir kein Paar gefunden haben, drehen wir zufällig
        // zwei Karten um
        if treffer == false {
            // so lange eine Zufallszahl suchen, bis eine Karte gefunden
            // wird, die noch im Spiel ist
            repeat {
                zufall = Int(arc4random_uniform(42))
            } while karten[zufall].getNochImSpiel() == false
            
            // die erste Karte umdrehen
            // karten[zufall].performClick(self)
            // die Vorderseite zeigen
            karten[zufall].vorderseiteZeigen()
            // und die Karte öffnen
            karteOeffnen(karte: karten[zufall])
            
            // für die zweite Karte müssen wir außerdem prüfen, ob sie
            // nicht gerade angezeigt wird
            repeat {
                zufall = Int(arc4random_uniform(42))
                // bitte in einer Zeile eingeben
            } while karten[zufall].getNochImSpiel() == false || karten[zufall].getUmgedreht() == true
            // und die zweite Karte umdrehen
            // karten[zufall].performClick(self)
            // die Vorderseite zeigen
            karten[zufall].vorderseiteZeigen()
            // und die Karte öffnen
            karteOeffnen(karte: karten[zufall])
        }
    }
    
    // die Methode liefert, ob Züge des Menschen erlaubt sind
    // die Rückgabe ist false, wenn gerade der Computer zieht oder
    // wenn schon zwei Karten umgedreht sind
    // sonst ist die Rückgabe true
    func zugErlaubt() -> Bool {
        var erlaubt = true
        // zieht der Computer?
        if spieler == 1 {
            erlaubt = false
        }
        
        // sind schon zwei Karten umdreht?
        if umgedrehteKarten == 2 {
            erlaubt = false
        }
        return erlaubt
    }
    
    // Spielstärke einstellen
    func spielstarkeVeraendern() {
        spielstaerke = spielstaerkeAnzeige.integerValue
        if starkeSlider.integerValue == 0 {
            spielstaerkeAnzeige.stringValue = "Profi"
            spielstaerke = 0
        } else if starkeSlider.integerValue == 2 {
            spielstaerkeAnzeige.stringValue = "Hart"
            spielstaerke = 2
        } else if starkeSlider.integerValue == 5 {
            spielstaerkeAnzeige.stringValue = "Mittel"
            spielstaerke = 5
        } else if starkeSlider.integerValue == 7 {
            spielstaerkeAnzeige.stringValue = "Einfach"
            spielstaerke = 7
        } else if starkeSlider.integerValue == 10 {
            spielstaerkeAnzeige.stringValue = "Baby"
            spielstaerke = 10
        }
    }
    
    // Schummeln
    @objc func schummel() {
        for card in karten {
            // deckt alle Karten wieder zu, die noch im Spiel sind
            // und umgedreht sind
            if card.getNochImSpiel() && card.getUmgedreht() {
                card.rueckseiteZeigen(rausnehmen: false)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func spielStarke(_ sender: Any) {
        spielstarkeVeraendern()
    }
    
    @IBAction func schummelClicked(_ sender: Any) {
        // Zeigt alle Karten die noch im Spiel sind und nicht
        // umgedreht wurden
        for card in karten {
            if card.getNochImSpiel() && !card.getUmgedreht() {
                card.vorderseiteZeigen()
            }
            
        }
        
        // blende den Button aus bevor der Timer startet
        schummelTaste.isEnabled = false
        
        // setzt den Timer auf 5 Sekunden
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(schummel), userInfo: nil, repeats: false)
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // das Spielfeld aufbauen und initialisieren
        initMeinSpielfeld()
        spielstarkeVeraendern()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

