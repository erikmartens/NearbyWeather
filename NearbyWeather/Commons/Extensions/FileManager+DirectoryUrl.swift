//
//  FileManager+DirectoryUrl.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum FileManagerError: String, Error {
  
  var domain: String {
    "FileManager"
  }
  
  case directoryUrlDeterminationError = "Could not determine the specified directory within the SearchPathDirectory"
}

extension FileManager {
  
  enum StorageLocationType {
    case bundle
    case documents
    case applicationSupport
  }
  
  func directoryUrl(for location: StorageLocationType, fileName: String? = nil, fileExtension: String? = nil) throws -> URL {
    var url: URL?
    
    switch location {
    case .bundle:
      url = Bundle.main.bundleURL
    case .documents:
      url = urls(for: .documentDirectory, in: .userDomainMask).first
    case .applicationSupport:
      url = urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }
    
    guard let result = url else {
      throw FileManagerError.directoryUrlDeterminationError
    }
    return result
  }
  
  func createBaseDirectoryIfNeeded(for filePath: String) throws {
    if fileExists(atPath: filePath, isDirectory: nil) {
      return
    }
    try createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
  }
}
