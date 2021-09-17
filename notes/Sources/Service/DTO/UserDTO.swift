import Foundation

struct UserDTO: Codable {
  let jwt: String?
  let id: String
  let name: String
  let email: String
}

extension User {
  init(dto: UserDTO) {
    id = .init(string: dto.id)
    name = dto.name
    email = dto.email
  }
}
