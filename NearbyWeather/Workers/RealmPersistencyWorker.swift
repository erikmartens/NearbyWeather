//
//  RealmPersistencyWorker.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 21.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift

protocol PersistencyModelProtocol {
  associatedtype T: Codable
  var identity: PersistencyModelIdentityProtocol { get }
  var entity: T { get }
  init(identity: PersistencyModelIdentityProtocol, entity: T)
  init?(collection: String, identifier: String, data: Data?)
  func toRealmModel() -> RealmModel
}

class PersistencyModel<T: Codable>: PersistencyModelProtocol {
  let identity: PersistencyModelIdentityProtocol
  let entity: T
  
  required init(
    identity: PersistencyModelIdentityProtocol,
    entity: T
  ) {
    self.identity = identity
    self.entity = entity
  }
  
  required init?(collection: String, identifier: String, data: Data?) {
    self.identity = PersistencyModelIdentity(collection: collection, identifier: identifier)
    guard let data = data,
      let entity = try? JSONDecoder().decode(T.self, from: data) else {
        return nil
    }
    self.entity = entity
  }
  
  func toRealmModel() -> RealmModel {
    RealmModel(
      collection: identity.collection,
      identifier: identity.identifier,
      data: try? JSONEncoder().encode(entity)
    )
  }
}

protocol PersistencyModelIdentityProtocol {
  var collection: String { get }
  var identifier: String { get }
}

struct PersistencyModelIdentity: PersistencyModelIdentityProtocol {
  let collection: String
  let identifier: String
}

internal class RealmModel: Object {
  
  @objc dynamic public var collection: String = ""
  @objc dynamic public var identifier: String = ""
  @objc dynamic public var data: Data?
  
  internal convenience init(collection: String, identifier: String, data: Data?) {
    self.init()
    self.collection = collection
    self.identifier = identifier
    self.data = data
  }
  
  override public static func indexedProperties() -> [String] {
    ["collection", "identifier"]
  }
}

enum RealmPersistencyWorkerError: String, Error {
  
  var domain: String {
    "RealmPersistencyWorker"
  }
  
  case realmConfigurationError = "Trying to access Realm with configuration, but an error occured."
  case dataEncodingError = "Trying to save a resource, but its information could not be encoded correctly."
}

final class RealmPersistencyWorker {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let baseDirectory: URL
  private let databaseFileName: String
  
  private lazy var configuration: Realm.Configuration = {
    Realm.Configuration(
      fileURL: databaseUrl,
      readOnly: false,
      migrationBlock: { (_, _) in },
      deleteRealmIfMigrationNeeded: false,
      objectTypes: [RealmModel.self]
    )
  }()
  
  private lazy var databaseUrl: URL = {
    baseDirectory.appendingPathComponent("\(databaseFileName).realm")
  }()
  
  private var realm: Realm? {
    try? Realm(configuration: configuration)
  }
  
  // MARK: - Initialization
  
  init(
    fileManager: FileManager = FileManager.default,
    storageLocation: FileManager.StorageLocationType,
    dataBaseFileName: String
  ) throws {
    self.baseDirectory = try fileManager.directoryUrl(for: storageLocation)
    self.databaseFileName = dataBaseFileName
    
    try fileManager.createBaseDirectoryIfNeeded(for: baseDirectory.path)
  }
}

// MARK: - Public CRUD Functions

protocol RealmPersistencyWorkerCRUD {
  func saveResources<T: Codable>(_ resources: [PersistencyModel<T>], type: T.Type) -> Completable
  func saveResource<T: Codable>(_ resource: PersistencyModel<T>, type: T.Type) -> Completable
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModel<T>]>
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModel<T>?>
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModel<T>]>
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModel<T>?>
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable
  func deleteResources(in collection: String) -> Completable
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable
}

extension RealmPersistencyWorker: RealmPersistencyWorkerCRUD {
  
  /// save a new set of resources or update already existing resources for the specified identities
  func saveResources<T: Codable>(_ resources: [PersistencyModel<T>], type: T.Type) -> Completable {
    Completable
      .create { [configuration] completable in
        do {
          let realm = try Realm(configuration: configuration)
          
          realm.beginWrite()
          
          try resources.forEach { resource in
            let newModel = resource.toRealmModel()
            
            guard newModel.data != nil else {
              throw RealmPersistencyWorkerError.dataEncodingError
            }
            
            let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", resource.identity.collection, resource.identity.identifier)
            
            // resource does not yet exist
            guard let existingModel = realm.objects(RealmModel.self).filter(predicate).first else {
              realm.add(newModel)
              return
            }
            
            // resource exists -> update if needed
            if existingModel.data != newModel.data {
              existingModel.data = newModel.data
            }
          }
          
          try realm.commitWrite()
          
          completable(.completed)
        } catch {
          completable(.error(error))
        }
        return Disposables.create()
    }
  }
  
  /// save a new resource or update an already existing resource for the specified identity
  func saveResource<T: Codable>(_ resource: PersistencyModel<T>, type: T.Type) -> Completable {
    Completable
      .create { [configuration] completable in
        let newModel = resource.toRealmModel()
        
        guard newModel.data != nil else {
          completable(.error(RealmPersistencyWorkerError.dataEncodingError))
          return Disposables.create()
        }
        
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", resource.identity.collection, resource.identity.identifier)
          
          // resource does not yet exist
          guard let existingModel = realm.objects(RealmModel.self).filter(predicate).first else {
            try realm.write {
              realm.add(newModel)
            }
            completable(.completed)
            return Disposables.create()
          }
          
          // resource exists -> update if needed
          if existingModel.data != newModel.data {
            try realm.write {
              existingModel.data = newModel.data
            }
          }
          completable(.completed)
        } catch {
          completable(.error(error))
        }
        return Disposables.create()
    }
  }
  
  /// returns a single containing all resources within a specified collection
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModel<T>]> {
    Single<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@", collection)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler(.success(results))
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
      }
      .map { results -> [PersistencyModel<T>] in
        results.compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
      }
  }
  
  /// returns a single containing a specified resource for a specified identity
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModel<T>?> {
    Single<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler(.success(results))
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
      }
      .map { results -> PersistencyModel<T>? in
        results
          .compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
          .first
      }
      .subscribeOn(MainScheduler.instance) // need to subscribe on a thread with runloop
      .observeOn(SerialDispatchQueueScheduler.init(qos: .default))
  }
  
  /// observes all resources within a specified collection
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModel<T>]> {
    Observable<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@", collection)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler.onNext(results)
        } catch {
          handler.onError(error)
        }
        return Disposables.create()
      }
      .map { results -> [PersistencyModel<T>] in
        results.compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
      }
      .subscribeOn(MainScheduler.instance) // need to subscribe on a thread with runloop
      .observeOn(SerialDispatchQueueScheduler.init(qos: .default))
  }
  
  /// observes a specified resource for a specified identity
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModel<T>?> {
    Observable<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler.onNext(results)
        } catch {
          handler.onError(error)
        }
        return Disposables.create()
      }
      .map { results -> PersistencyModel<T>? in
        results
          .compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
          .first
      }
      .subscribeOn(MainScheduler.instance) // need to subscribe on a thread with runloop
      .observeOn(SerialDispatchQueueScheduler.init(qos: .default))
  }
  
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable {
    Completable
      .create { [configuration] handler -> Disposable in
        do {
          let realm = try Realm(configuration: configuration)
          realm.beginWrite()
          identities.forEach { identity in
            let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
            let identifiedObject = realm
              .objects(RealmModel.self)
              .filter(predicate)
            realm.delete(identifiedObject)
          }
          try realm.commitWrite()
          handler(.completed)
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
    }
  }
  
  func deleteResources(in collection: String) -> Completable {
    Completable
      .create { [configuration] handler -> Disposable in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@", collection)
          let identifiedObjects = realm
            .objects(RealmModel.self)
            .filter(predicate)
          
          try realm.write {
            realm.delete(identifiedObjects)
          }
          handler(.completed)
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
    }
  }
  
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable {
    Completable
      .create { [configuration] handler -> Disposable in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
          let identifiedObject = realm
            .objects(RealmModel.self)
            .filter(predicate)
          
          try realm.write {
            realm.delete(identifiedObject)
          }
          
          handler(.completed)
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
    }
  }
}
