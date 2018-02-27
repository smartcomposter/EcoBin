//
//  BLEManager.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-01-29.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import Foundation
import CoreBluetooth

private struct BLEConstants {
    static let TemperatureService = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    static let RXCharacteristic = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    static let TXCharacteristic = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
}

private struct Weak<T: AnyObject> {
    weak var object: T?
}

protocol BLEManagable {
    func startScanning()
    func stopScanning()
    func disconnectPeripheral()
    func writeValue(value: UInt8)
    
    func addDelegate(_ delegate: BLEManagerDelegate)
    func removeDelegate(_ delegate: BLEManagerDelegate)
}

protocol BLEManagerDelegate: AnyObject {
    func bleManagerDidConnect(_ manager: BLEManagable)
    func bleManagerDidDisconnect(_ manager: BLEManagable)
    func bleManager(_ manager: BLEManagable, receivedDataString dataString: String)
}

class BLEManager: NSObject, BLEManagable {
    
    fileprivate var shouldStartScanning = false
    
    private var centralManager: CBCentralManager?
    private var isCentralManagerReady: Bool {
        get {
            guard let centralManager = centralManager else {
                return false
            }
            return centralManager.state != .poweredOff && centralManager.state != .unauthorized && centralManager.state != .unsupported
        }
    }
    
    fileprivate var connectingPeripheral: CBPeripheral?
    fileprivate var connectedPeripheral: CBPeripheral?
    
    var writableCharacteristic: CBCharacteristic?
    
    fileprivate var delegates: [Weak<AnyObject>] = []
    fileprivate func bleDelegates() -> [BLEManagerDelegate] {
        return delegates.flatMap { $0.object as? BLEManagerDelegate }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
        startScanning()
    }
    
    func startScanning() {
        print ("Start scanning")
        guard let centralManager = centralManager, isCentralManagerReady == true else {
            print("Central manager is not ready")
            return
        }
        
        if centralManager.state != .poweredOn {
            print("Should start scanning")
            shouldStartScanning = true
        } else {
            print("Should not start scanning")
            shouldStartScanning = false
            centralManager.scanForPeripherals(withServices: [BLEConstants.TemperatureService], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func stopScanning() {
        print ("Stop scanning")
        shouldStartScanning = false
        centralManager?.stopScan()
    }
    
    func disconnectPeripheral() {
        stopScanning()
        if (connectedPeripheral != nil) {
            print("disconected with connected peripheral")
            shouldStartScanning = false;
            centralManager?.cancelPeripheralConnection(connectedPeripheral!)
        } else if (connectingPeripheral != nil) {
            print("disconected with connecting peripheral")
            shouldStartScanning = false;
            centralManager?.cancelPeripheralConnection(connectingPeripheral!)
        }
    }
    
    func writeValue(value: UInt8) {
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            print("no peripheral")
            return
        }

        let data = Data(bytes: [value])
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func addDelegate(_ delegate: BLEManagerDelegate) {
//        print("Add Delegate")
        delegates.append(Weak(object: delegate))
    }
    
    func removeDelegate(_ delegate: BLEManagerDelegate) {
//        print("Remove Delegate")
        if let index = delegates.index(where: { $0.object === delegate }) {
            delegates.remove(at: index)
        }
    }
}

// MARK: CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("centralManagerDidUpdateState")
        if central.state == .poweredOn {
            if self.shouldStartScanning {
                self.startScanning()
            }
        } else {
            self.connectingPeripheral = nil
            if let connectedPeripheral = self.connectedPeripheral {
                central.cancelPeripheralConnection(connectedPeripheral)
            }
            self.shouldStartScanning = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("centralManagerDidDiscoverPeripheral")
        self.connectingPeripheral = peripheral
        central.connect(peripheral, options: nil)
        self.stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("centralManagerDidConnectPeripheral")
        self.connectedPeripheral = peripheral
        self.connectingPeripheral = nil
        
        peripheral.discoverServices([BLEConstants.TemperatureService])
        peripheral.delegate = self
        
        self.informDelegatesDidConnect(manager: self)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManagerDidFailToConnectPeripheral")
        self.connectingPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("centralManagerDidDisconnectPeripheral")
        self.connectedPeripheral = nil
        if (shouldStartScanning) {
            self.startScanning()
        }
        self.informDelegatesDidDisconnect(manager: self)
    }
}

// MARK: CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("peripheralDidDiscoverServices")
        if let tempService = peripheral.services?.filter({ $0.uuid.uuidString.uppercased() == BLEConstants.TemperatureService.uuidString.uppercased() }).first {
            peripheral.discoverCharacteristics([BLEConstants.RXCharacteristic, BLEConstants.TXCharacteristic], for: tempService)
        } else {
            print("tempt service not available")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        print("peripheralDidDiscoverCharacteristicsForServices")
        if let rxCharacteristic = service.characteristics?.filter({ $0.uuid.uuidString.uppercased() == BLEConstants.RXCharacteristic.uuidString.uppercased()}).first,
            let txCharacteristic = service.characteristics?.filter({ $0.uuid.uuidString.uppercased() == BLEConstants.TXCharacteristic.uuidString.uppercased()}).first {
            peripheral.setNotifyValue(true, for: rxCharacteristic)
            peripheral.setNotifyValue(true, for: txCharacteristic)
            writableCharacteristic = txCharacteristic
        } else {
            print("did not discover characteristic")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("peripheralDidUpdateValueForCharacteristic")
        guard let temperatureData = characteristic.value else {
            print("value does not exist")
            return
        }
        
        if characteristic == writableCharacteristic {
            print("data received: " + String(describing: temperatureData))
        }
        
        if let dataString = NSString.init(data: temperatureData, encoding: String.Encoding.utf8.rawValue) as String? {
            self.informDelegatesDidReceiveData(manager: self, dataString: dataString)
        }
    }
}

// MARK: Delegate Callbacks
extension BLEManager {
    
    func informDelegatesDidConnect(manager: BLEManager) {
//        print("informDelegatesDidConnect")
        for delegate in self.bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManagerDidConnect(manager)
            }
        }
    }
    
    func informDelegatesDidDisconnect(manager: BLEManager) {
//        print("informDelegatesDidDisconnect")
        for delegate in self.bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManagerDidDisconnect(manager)
            }
        }
    }
    
    func informDelegatesDidReceiveData(manager: BLEManager, dataString: String) {
//        print("informDelegatesDidReceiveData")
        for delegate in self.bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManager(manager, receivedDataString: dataString)
            }
        }
    }
}
