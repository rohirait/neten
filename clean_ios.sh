rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf ~/Library/Caches/CocoaPods/
(cd ios && pod deintegrate && pod update && pod install)