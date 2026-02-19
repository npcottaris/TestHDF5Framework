## STEP 1: Install CMake
```
brew install cmake ninja
```


## STEP 2: Download and extract
```
curl -O https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.3/src/hdf5-1.14.3.tar.gz
tar -xzf hdf5-1.14.3.tar.gz
cd hdf5-1.14.3
mkdir build && cd build
```

## STEP 3: Configure xCode
```
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcode-select -p
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

## STEP 4: Build it for Apple Silicon
### STEP 4a:

```
cmake .. \
    -G Ninja \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/hdf5-macos" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DHDF5_BUILD_TOOLS=OFF \
    -DHDF5_BUILD_EXAMPLES=OFF \
    -DHDF5_BUILD_FORTRAN=OFF \
    -DHDF5_BUILD_CPP_LIB=OFF \
    -DHDF5_BUILD_HL_LIB=ON \
    -DHDF5_ENABLE_Z_LIB_SUPPORT=OFF \
    -DHDF5_ENABLE_SZIP_SUPPORT=OFF

cmake --build . --config Release
cmake --install .
```

### STEP 4b: Verify the binary
```
lipo -info "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/hdf5-macos/lib/libhdf5.a"
```

### STEP 4c: Package as an Xcode Framework
```
xcodebuild -create-xcframework \
    -library "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/hdf5-macos/lib/libhdf5.a" \
    -headers "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/hdf5-macos/include" \
    -output "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/HDF5.xcframework"
```


### STEP 4d: Add the modulemap:
```
cat > "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/HDF5.xcframework/macos-arm64/Headers/module.modulemap" <<EOF
module HDF5 [system] {
    header "hdf5.h"
    export *
}
EOF
```

### STEP 4e: Verify that it worked

```
cat "$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/HDF5.xcframework/macos-arm64/Headers/module.modulemap"
```
You should see:
```
module HDF5 [system] {
    header "hdf5.h"
    export *
}
```

## STEP 5: Build a test project
### STEP 5e: Generate Xcode project

In Xcode generate a new MacOS app project. Then modify the ContentView.swift as follows:

```
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
        .onTapGesture {test() }
       
    }

    func test() {
        H5open()                 //initializes the library and returns non-negative on success
        let status = H5open()
        assert(status >= 0, "HDF5 failed to initialize")
        print("HDF5 version: \(H5_VERS_MAJOR).\(H5_VERS_MINOR).\(H5_VERS_RELEASE)")
    }

    
}

#Preview {
    ContentView()
}

```

### STEP 5b: Add the HDF5.xcframework 
In the Xcode project, click on File -> Add Files to App and add the entire folder 
`$HOME/Developer/Swift/TestHDF5Framework/HDF5frameworkResources/HDF5.xcframework`
with the option to copy.

Then in ContentView.swift add
```
import HDF5
```

Compile the project and click on the world icon. It should print the version of the library
```
HDF5 version: 1.14.3
```
