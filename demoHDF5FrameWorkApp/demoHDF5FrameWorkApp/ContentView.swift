//
//  ContentView.swift
//  demoHDF5FrameWorkApp
//
//  Created by Nicolas Cottaris on 2/19/26.
//

import SwiftUI
import HDF5

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onTapGesture {
            testHDF5()
        }
    }
}

#Preview {
    ContentView()
}


func testHDF5() {
        H5open()                 //initializes the library and returns non-negative on success
        let status = H5open()
        assert(status >= 0, "HDF5 failed to initialize")
        print("HDF5 version: \(H5_VERS_MAJOR).\(H5_VERS_MINOR).\(H5_VERS_RELEASE)")
    }

