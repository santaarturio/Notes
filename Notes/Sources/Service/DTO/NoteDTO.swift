import Foundation

struct NoteDTO: Codable {
  let id: String
  let title: String
  let subtitle: String
}

extension Note {
  init(dto: NoteDTO) {
    id = .init(string: dto.id)
    title = dto.title
    text = dto.subtitle
  }
}
