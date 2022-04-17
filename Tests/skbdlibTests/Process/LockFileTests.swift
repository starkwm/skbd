import XCTest

@testable import skbdlib

final class LockFileTests: XCTestCase {
    // MARK: Lifecycle

    override func setUp() {
        super.setUp()

        setenv("USER", String(Int.random(in: 1000 ... 9999)), 1)
    }

    override func tearDown() {
        super.tearDown()

        try? FileManager.default.removeItem(atPath: try LockFile.path())

        LockFile.open = defaultOpen
        LockFile.fcntl = defaultFcntl
        LockFile.flock = defaultFlock
        LockFile.write = defaultWrite
        LockFile.read = defaultRead
    }

    // MARK: LockFile.acquire

    func testAcquire() {
        XCTAssertNoThrow(try LockFile.acquire())
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LockFile.path()))
    }

    func testAcquireWithOpenFail() {
        LockFile.open = { _, _, _ in -1 }

        XCTAssertThrowsError(try LockFile.acquire()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToOpenFile)
        }
    }

    func testAcquireWithFcntlFail() {
        LockFile.fcntl = { _ in -1 }

        XCTAssertThrowsError(try LockFile.acquire()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToLockFile)
        }
    }

    func testAcquireWithWriteFail() throws {
        LockFile.write = { _ in -1 }

        XCTAssertThrowsError(try LockFile.acquire()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToWriteFile)
        }
    }

    // MARK: LockFile.readPid

    func testReadPid() {
        XCTAssertNoThrow(try LockFile.acquire())
        XCTAssertEqual(try LockFile.readPid(), getpid())
    }

    func testReadPidWithOpenFail() {
        XCTAssertNoThrow(try LockFile.acquire())

        LockFile.open = { _, _, _ in -1 }

        XCTAssertThrowsError(try LockFile.readPid()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToOpenFile)
        }
    }

    func testReadPidWithLockFail() {
        XCTAssertNoThrow(try LockFile.acquire())

        LockFile.flock = { _ in 0 }

        XCTAssertThrowsError(try LockFile.readPid()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToLockFile)
        }
    }

    func testReadPidWithReadFail() {
        XCTAssertNoThrow(try LockFile.acquire())

        LockFile.read = { _ in (Int(-1), Int32(0)) }

        XCTAssertThrowsError(try LockFile.readPid()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .failedToReadFile)
        }
    }

    // MARK: LockFile.path

    func testPathWithNoUser() {
        unsetenv("USER")

        XCTAssertThrowsError(try LockFile.path()) { err in
            XCTAssertTrue(err is LockFileError)
            XCTAssertEqual(err as? LockFileError, .userEnvVarMissing)
        }
    }
}
