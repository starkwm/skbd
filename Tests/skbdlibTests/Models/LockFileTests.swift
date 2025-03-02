import Foundation
import Testing

@testable import skbdlib

@Suite("LockFile", .serialized)
class LockFileTests {
  init() {
    setenv("USER", String(Int.random(in: 10000...99999)), 1)
  }

  deinit {
    try? FileManager.default.removeItem(atPath: LockFile.path())

    LockFile.open = defaultOpen
    LockFile.fcntl = defaultFcntl
    LockFile.flock = defaultFlock
    LockFile.write = defaultWrite
    LockFile.read = defaultRead
  }

  // MARK: - LockFile.acquire

  @Test("LockFile.acquire() (with no errors)")
  func acquireWithNoErrors() async throws {
    #expect(throws: Never.self) {
      try LockFile.acquire()

      #expect(FileManager.default.fileExists(atPath: try LockFile.path()))
    }
  }

  @Test("LockFile.acquire() (when open call fails)")
  func acquireWhenOpenFails() async throws {
    LockFile.open = { _, _, _ in -1 }

    #expect(throws: LockFileError.failedToOpenFile) {
      try LockFile.acquire()
    }
  }

  @Test("LockFile.acquire() (when fcntl call fails)")
  func acquireWhenFcntlFails() async throws {
    LockFile.fcntl = { _ in -1 }

    #expect(throws: LockFileError.failedToLockFile) {
      try LockFile.acquire()
    }
  }

  @Test("LockFile.acquire() (when write call fails)")
  func acquireWhenWriteFails() async throws {
    LockFile.write = { _ in -1 }

    #expect(throws: LockFileError.failedToWriteFile) {
      try LockFile.acquire()
    }
  }

  // MARK: - LockFile.readPID

  @Test("LockFile.readPID() (with no errors)")
  func readPIDWithNoErrors() async throws {
    #expect(throws: Never.self) {
      try LockFile.acquire()

      #expect(try LockFile.readPID() == getpid())
    }
  }

  @Test("LockFile.readPID() (when open call fails)")
  func readPIDWhenOpenFails() async throws {
    #expect(throws: Never.self) {
      try LockFile.acquire()
    }

    LockFile.open = { _, _, _ in -1 }

    #expect(throws: LockFileError.failedToOpenFile) {
      try LockFile.readPID()
    }
  }

  @Test("LockFile.readPID() (when flock call fails)")
  func readPIDWhenFlockFails() async throws {
    #expect(throws: Never.self) {
      try LockFile.acquire()
    }

    LockFile.flock = { _ in 0 }

    #expect(throws: LockFileError.failedToLockFile) {
      try LockFile.readPID()
    }
  }

  @Test("LockFile.readPID() (when read call fails)")
  func readPIDWhenReadFails() async throws {
    #expect(throws: Never.self) {
      try LockFile.acquire()
    }

    LockFile.read = { _ in (Int(-1), Int32(0)) }

    #expect(throws: LockFileError.failedToReadFile) {
      try LockFile.readPID()
    }
  }

  // MARK: - LockFile.path

  @Test("LockFile.path() (with no errors)")
  func pathWithNoErrors() async throws {
    #expect(throws: Never.self) {
      try LockFile.path()
    }
  }

  @Test("LockFile.path() (when no USER enviornment variable set)")
  func pathWithNoUserEnvVar() async throws {
    unsetenv("USER")

    #expect(throws: LockFileError.userEnvVarMissing) {
      try LockFile.path()
    }
  }
}
