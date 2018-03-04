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
    static let nRF8001BLEService = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    static let nRF8001CharacteristicRX = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    static let nRF8001CharacteristicTX = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
}

private struct Weak<T: AnyObject> {
    weak var object: T?
}

protocol BLEManagable {
    func startScanning()
    func stopScanning()
    func disconnectPeripheral()
    func sendData()
    
    func addDelegate(_ delegate: BLEManagerDelegate)
    func removeDelegate(_ delegate: BLEManagerDelegate)
}

protocol BLEManagerDelegate: AnyObject {
    func bleManagerDidConnect(_ manager: BLEManagable)
    func bleManagerDidDisconnect(_ manager: BLEManagable)
    func bleManager(_ manager: BLEManagable, receivedDataString dataString: String)
}

class BLEManager: NSObject, BLEManagable {
    
    fileprivate var shouldStartScanning = true
    fileprivate var delegates: [Weak<AnyObject>] = []
    fileprivate var BLEPeripheral: CBPeripheral?
    private var centralManager: CBCentralManager?
    private var txCharacteristic : CBCharacteristic?
    private var rxCharacteristic : CBCharacteristic?
    
    private var isCentralManagerReady: Bool {
        get {
            guard let centralManager = centralManager else {
                return false
            }
            return centralManager.state != .poweredOff && centralManager.state != .unauthorized && centralManager.state != .unsupported
        }
    }
    
    fileprivate func bleDelegates() -> [BLEManagerDelegate] {
        return delegates.flatMap { $0.object as? BLEManagerDelegate }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
        startScanning()
    }
    
    func startScanning() {
        guard let centralManager = centralManager, isCentralManagerReady == true else {
            print("Central manager is not ready")
            return
        }
        
        if centralManager.state != .poweredOn {
            print("Central manager is not powered on")
            shouldStartScanning = true
        } else {
            shouldStartScanning = false
            centralManager.scanForPeripherals(withServices: [BLEConstants.nRF8001BLEService], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func stopScanning() {
        shouldStartScanning = false
        centralManager?.stopScan()
    }
    
    func disconnectPeripheral() {
        stopScanning()
        if let peripheral = BLEPeripheral {
            print("Canceling peripheral connection")
            shouldStartScanning = false;
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func addDelegate(_ delegate: BLEManagerDelegate) {
        delegates.append(Weak(object: delegate))
    }
    
    func removeDelegate(_ delegate: BLEManagerDelegate) {
        if let index = delegates.index(where: { $0.object === delegate }) {
            delegates.remove(at: index)
        }
    }
    
    func sendData() {
        if let data = "apple".data(using: String.Encoding.ascii), let sendCharacteristic = txCharacteristic {
            BLEPeripheral?.writeValue(data, for: sendCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            if let value = String(data: data, encoding: String.Encoding.ascii) {
                print("Value sent: ", value)
            }
        }
    }
}

// MARK: CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if shouldStartScanning {
                startScanning()
            }
        } else {
            if let connectedPeripheral = BLEPeripheral {
                central.cancelPeripheralConnection(connectedPeripheral)
            }
            shouldStartScanning = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        BLEPeripheral = peripheral
        central.connect(peripheral, options: nil)
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([BLEConstants.nRF8001BLEService])
        informDelegatesDidConnect(manager: self)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManagerDidFailToConnectPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("centralManagerDidDisconnectPeripheral")
        BLEPeripheral = nil
        if (shouldStartScanning) {
            startScanning()
        }
        informDelegatesDidDisconnect(manager: self)
    }
}

// MARK: CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("No service available")
            return
        }
        
        for service in services {
            if service.uuid.uuidString.uppercased().isEqual(BLEConstants.nRF8001BLEService.uuidString.uppercased()) {
                peripheral.discoverCharacteristics([BLEConstants.nRF8001CharacteristicRX, BLEConstants.nRF8001CharacteristicTX], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("No characteristics available")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid.uuidString.uppercased().isEqual(BLEConstants.nRF8001CharacteristicRX.uuidString.uppercased())  {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid.uuidString.uppercased().isEqual(BLEConstants.nRF8001CharacteristicTX.uuidString.uppercased())  {
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else {
            print("value does not exist")
            return
        }
        
        if characteristic == rxCharacteristic {
            if let dataString = NSString.init(data: value, encoding: String.Encoding.utf8.rawValue) as String? {
                informDelegatesDidReceiveData(manager: self, dataString: dataString)
            }
        }
    }
}

// MARK: Delegate Callbacks
extension BLEManager {
    
    func informDelegatesDidConnect(manager: BLEManager) {
        for delegate in bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManagerDidConnect(manager)
            }
        }
    }
    
    func informDelegatesDidDisconnect(manager: BLEManager) {
        for delegate in bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManagerDidDisconnect(manager)
            }
        }
    }
    
    func informDelegatesDidReceiveData(manager: BLEManager, dataString: String) {
        for delegate in bleDelegates() {
            DispatchQueue.main.async {
                delegate.bleManager(manager, receivedDataString: dataString)
            }
        }
    }
}
