#! /bin/bash

if ! [ -x "$(command -v cargo)" ]; then
  echo 'Cargo is not installed! Please install using rustup.'
  exit 1
fi

if ! [ -x "$(command -v dotnet)" ]; then
  echo 'Dotnet is not installed! Please install using install scripts from microsoft.'
  exit 1
fi

# build core
cd ./shulker-core
cargo build --release
cd ..
cp ./shulker-core/target/release/shulker-core ./core
rm -rf ./shulker-core/target

# build connect
cd ./shulker-connect/DoorlockServerAPI
dotnet build --configuration Release
cd ../..
cp -r ./shulker-connect/DoorlockServerAPI/bin/Release/net5.0 ./connect

#run DoorlockServerAPI with --urls "http://10.0.0.154:42001"