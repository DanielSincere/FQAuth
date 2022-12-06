import Vapor

// from https://github.com/vapor/vapor/blob/300565186f5ef57494d5b9df6bfb68bf6e2ec053/Sources/Vapor/Services/App%2BService.swift

extension Application {
  struct Services {
    
    let application: Application

  }
  
  var services: Services {
    .init(application: self)
  }
}
