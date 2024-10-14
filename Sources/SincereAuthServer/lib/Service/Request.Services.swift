import Vapor

// from https://github.com/vapor/vapor/blob/300565186f5ef57494d5b9df6bfb68bf6e2ec053/Sources/Vapor/Services/Req%2BService.swift

extension Request {
  public struct Services {
    let request: Request
    init(request: Request) {
      self.request = request
    }
  }
  
  public var services: Services {
    Services(request: self)
  }
}
