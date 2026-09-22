import Foundation
import Testing

@testable import SkbdCore

@Suite("FileLock")
struct FileLockTests {
  @Test("A failed contender leaves the active lock intact")
  func contention() throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: file) }

    let owner = FileLock(path: file.path)

    try owner.acquire().get()

    do {
      let contender = FileLock(path: file.path)

      #expect(throws: FileLockError.alreadyLocked) {
        try contender.acquire().get()
      }
    }

    let next = FileLock(path: file.path)

    #expect(throws: FileLockError.alreadyLocked) {
      try next.acquire().get()
    }

    owner.release()
    try next.acquire().get()

    let contender = FileLock(path: file.path)

    #expect(throws: FileLockError.alreadyLocked) {
      try contender.acquire().get()
    }
  }

  @Test("Acquiring twice keeps the same lock")
  func repeatedAcquire() throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: file) }

    let lock = FileLock(path: file.path)

    try lock.acquire().get()
    try lock.acquire().get()
    lock.release()

    let next = FileLock(path: file.path)

    try next.acquire().get()
  }
}
