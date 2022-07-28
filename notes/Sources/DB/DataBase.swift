enum DataBaseManager {
  static let notes = CoreDataManager(containerName: "NotesData")
}

enum DataBase {
  static let notes: NotesDataBaseProtocol = NotesDataBase(coreDataManager: DataBaseManager.notes)
}
