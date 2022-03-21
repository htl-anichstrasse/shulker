#! /bin/bash

if ! [ -x "$(command -v cargo)" ]; then
  echo 'Cargo is not installed! Please install using rustup.'
  exit 1
fi

# build core
cd ./shulker-core
cargo build --release
cd ..
cp ./shulker-core/target/release/shulker-core ./core
rm -rf ./shulker-core/target

# build connect
