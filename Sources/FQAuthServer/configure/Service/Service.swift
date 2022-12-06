// https://raw.githubusercontent.com/vapor/vapor/300565186f5ef57494d5b9df6bfb68bf6e2ec053/Sources/Vapor/Services/Service.swift
import Vapor

extension Application {
  public struct Service<ServiceType> {
    
    let application: Application
    
    public init(application: Application) {
      self.application = application
    }
    
    public struct Provider {
      let run: (Application) -> ()
      
      public init(_ run: @escaping (Application) -> ()) {
        self.run = run
      }
    }
    
    final class Storage {
      var makeService: ((Application) -> ServiceType)?
      init() { }
    }
    
    struct Key: StorageKey {
      typealias Value = Storage
    }
    
    public var service: ServiceType {
      guard let makeService = self.storage.makeService else {
        fatalError("No service configured for \(ServiceType.self)")
      }
      return makeService(self.application)
    }
    
    public func use(_ provider: Provider) {
      provider.run(self.application)
    }
    
    public func use(_ makeService: @escaping (Application) -> ServiceType) {
      self.storage.makeService = makeService
    }
    
    func initialize() {
      self.application.storage[Key.self] = .init()
    }
    
    private var storage: Storage {
      if self.application.storage[Key.self] == nil {
        self.initialize()
      }
      return self.application.storage[Key.self]!
    }
  }
}
