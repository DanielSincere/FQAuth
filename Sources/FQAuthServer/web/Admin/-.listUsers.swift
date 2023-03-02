import Vapor

extension AdminWebController {
  func listUsers(req: Request) async throws -> View {
    let users = try await UserModel.query(on: req.db(.psql)).all()
    return try await req.view.render("Admin/list-users", ["users": users])
  }
}
