
build-apk:
    flutter build apk --release --obfuscate --split-debug-info=./ -t lib/main_live.dart --flavor live

build-apk-beta:
    flutter build apk --release --obfuscate --split-debug-info=./ -t lib/main_beta.dart --flavor beta

# Clean dependencies
clean:
    flutter clean
    flutter pub get

# Generated and wacth code with build runner
codegen-watch:
    flutter pub run build_runner watch

# Delete conflicting and generated code with build runner 
codegen-build-delete:
    dart run build_runner build --delete-conflicting-outputs

codegen-build:
    dart run build_runner build

# Delete conflicting and generated code with build runner 
codegen-build-tests:
    flutter pub run build_runner build -c test 

# Generate i10n
i10n:
    flutter pub run easy_localization:generate -S assets/translations -f keys -O lib/generated -o locale_keys.g.dart

