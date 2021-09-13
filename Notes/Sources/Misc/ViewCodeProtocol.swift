
protocol ViewCode {
  
  func setupViewHierarchy()
  func setupConstraints()
  func setupAdditionalConfiguration()
  
  func setupView()
}

extension ViewCode {
  
  func setupView() {
    setupViewHierarchy()
    setupConstraints()
    setupAdditionalConfiguration()
  }
  
  func setupAdditionalConfiguration() { }
}
