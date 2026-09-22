import Darwin
import Foundation

public class FileLock {
  private let path: String
  private var fd: Int32 = -1

  public convenience init() {
    self.init(
      path: FileManager.default.temporaryDirectory
        .appendingPathComponent("skbd_next_\(NSUserName()).lock").path
    )
  }

  init(path: String) {
    self.path = path
  }

  deinit {
    release()
  }

  public func acquire() -> Result<Void, FileLockError> {
    guard fd == -1 else { return .success(()) }

    let descriptor = open(path, O_CREAT | O_WRONLY | O_CLOEXEC, 0o600)

    guard descriptor != -1 else {
      return .failure(.failed(reason: "failed to open lock file"))
    }

    guard flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
      let error: FileLockError =
        errno == EWOULDBLOCK ? .alreadyLocked : .failed(reason: "failed to acquire lock")

      close(descriptor)

      return .failure(error)
    }

    fd = descriptor

    return .success(())
  }

  func release() {
    guard fd != -1 else { return }

    // Keep the file so every contender locks the same inode.
    flock(fd, LOCK_UN)
    close(fd)

    fd = -1
  }
}
