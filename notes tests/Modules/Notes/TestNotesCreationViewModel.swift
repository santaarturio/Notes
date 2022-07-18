//
//  TestNotesCreationViewModel.swift
//  notes tests
//
//  Created by Artur Nikolaienko on 18.07.2022.
//

import XCTest

class NotesCreationViewModelTests: XCTestCase {
    
    var viewModel: NotesCreationViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = NotesCreationViewModel(notesAPI: NotesAPIStub(), notesDataBase: NotesDataBaseStub())
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        viewModel = nil
    }
    
    func testDoneButtonAvailable() {
        viewModel.title = "title"
        viewModel.body = "body"
        
        XCTAssertNotNil(viewModel.done)
    }
    
    func testPerformanceViewModel() throws {
        measure(
            metrics: [
                XCTMemoryMetric()
            ]
        ) { viewModel.done?() }
    }
}
