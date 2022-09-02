//
//  File.swift
//  
//
//  Created by Full Queue Developer on 9/2/22.
//

import Foundation

enum AllMigrations: CaseIterable {
  case function,
       user,
       siwa,
       refreshToken

  var migration: PostgresScriptMigration {
    switch self {
    case .function:
      return CreateFunctionMigration()
    case .user:
      return CreateUserMigration()
    case .siwa:
      return CreateSiwaMigration()
    case .refreshToken:
      return CreateRefreshTokenMigration()
    }
  }
}
