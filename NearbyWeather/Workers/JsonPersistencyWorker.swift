//
//  DataStorageService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol JsonPersistencyProtocol {
  associatedtype StorageEntity: JsonPersistencyProtocol
  
  static func storeData()
  static func loadData() -> StorageEntity?
}

enum JsonPersistencyWorkerError: String, Error {
  
  var domain: String {
    "JsonPersistencyWorker"
  }
  
  case fileNotFoundError = "Tried to retrieve a file from disk, but the file did not exist."
}

final class JsonPersistencyWorker {
  
  private static let fileExtension = "json"
  
  // MARK: - Properties
  
  private let fileManager: FileManager
  
  // MARK: - Initialization
  
  init(fileManager: FileManager = FileManager.default) {
    self.fileManager = fileManager
  }
  
  // MARK: - Public Functions
  
  func storeJson<T: Encodable>(for codable: T, inFileWithName fileName: String, toStorageLocation location: FileManager.StorageLocationType) throws {
    let destinationDirectoryURL = try fileManager.directoryUrl(for: location)
    let destinationFileUrl = destinationDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(Self.fileExtension)
    
    try fileManager.createBaseDirectoryIfNeeded(for: destinationDirectoryURL.path)
    let data = try JSONEncoder().encode(codable)
    try data.write(to: destinationFileUrl)
  }
  
  func retrieveJsonFromFile<T: Decodable>(with fileName: String, andDecodeAsType type: T.Type, fromStorageLocation location: FileManager.StorageLocationType) throws -> T {
    let fileDirectoryURL = try fileManager.directoryUrl(for: location, fileName: fileName, fileExtension: JsonPersistencyWorker.fileExtension)
    let fileUrl = fileDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(Self.fileExtension)
    
    guard fileManager.fileExists(atPath: fileUrl.path) else {
      throw JsonPersistencyWorkerError.fileNotFoundError
    }
    let data = try Data(contentsOf: fileUrl)
    let model = try JSONDecoder().decode(type, from: data)
    return model
  }
}
