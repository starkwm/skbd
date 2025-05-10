public protocol Presentable {
  var isVisible: Bool { get }

  func show()
  func hide()
}
