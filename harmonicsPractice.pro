lessThan(QT_MAJOR_VERSION,6): error("Qt6 is required for this build.")

#TODO

#Menu: Language | Info | Tuning | I like this app! - layout (left margin), size, landscape

#Menu button (Hamburger)

#Better help dialog window

QT += quick core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


VERSION = 0.2.1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"


#!NB use cmake to build for android qt Qt6! (supports multi-abi)
ANDROID_VERSION_NAME = $$VERSION
ANDROID_VERSION_CODE = 3 # build number
#TARGET = "Harmonics\ Practice" # for %%INSERT_APP_NAME%% but that cannot include spaces.


SOURCES += main.cpp \
        csengine.cpp

HEADERS += \
    csengine.h

RESOURCES += resources.qrc

#DEFINES += USE_DOUBLE # <- very strange! thi has to be commented out to work on Csound 6.12 (android)

# this is correct only for linux, later add a condition



android {

  INCLUDEPATH += /home/tarmo/src/csound-6.12.2/include/ /home/tarmo/src/csound-6.12.2/Android/CsoundAndroid/jni/

  HEADERS += /home/tarmo/src/csound-6.12.2/Android/CsoundAndroid/jni/AndroidCsound.hpp
  LIBS +=  -L/home/tarmo/src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/ -lcsoundandroid -lsndfile -lc++_shared #-loboe

    ANDROID_EXTRA_LIBS = \
        /home/tarmo/src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libsndfile.so \
        /home/tarmo/src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libcsoundandroid.so \
        /home/tarmo/src/csound-android-6.12.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libc++_shared.so

    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android

} else: linux {
  INCLUDEPATH += /usr/local/include/csound/

  LIBS += -lcsound64 -lsndfile
}

ios {


    csdfiles.files = harmonicsPractice.csd
    QMAKE_BUNDLE_DATA += csdfiles

    QMAKE_INFO_PLIST = $$PWD/ios/Info.plist

    QMAKE_ASSET_CATALOGS += $$PWD/ios/Assets.xcassets
    QMAKE_ASSET_CATALOGS_APP_ICON = AppIcon

    QMAKE_IOS_LAUNCH_SCREEN = $$PWD/ios/LaunchScreen.storyboard






    SOURCES += \
        csoundproxy.mm \
        csound-iOS/classes/CsoundObj.m \
        ios-screen.mm \


    HEADERS += \
        csound-iOS/classes/CsoundObj.h \
        csoundproxy.h \
        ios-screen.h \


    SOURCES -= csengine.cpp
    HEADERS -= csengine.h

    HEADERS += \
        csound-iOS/classes/bindings/motion/CsoundAccelerometerBinding.h \
        csound-iOS/classes/bindings/motion/CsoundAttitudeBinding.h \
        csound-iOS/classes/bindings/motion/CsoundGyroscopeBinding.h \
        csound-iOS/classes/bindings/motion/CsoundMotion.h \
        csound-iOS/classes/bindings/ui/CsoundButtonBinding.h \
        csound-iOS/classes/bindings/ui/CsoundLabelBinding.h \
        csound-iOS/classes/bindings/ui/CsoundMomentaryButtonBinding.h \
        csound-iOS/classes/bindings/ui/CsoundSliderBinding.h \
        csound-iOS/classes/bindings/ui/CsoundSwitchBinding.h \
        csound-iOS/classes/bindings/ui/CsoundUI.h \
        csound-iOS/classes/midi/CsoundMIDI.h \
        csound-iOS/classes/midi/MidiWidgetWrapper.h \
        csound-iOS/classes/midi/MidiWidgetsManager.h \
        csound-iOS/classes/midi/SliderMidiWidgetWrapper.h

    SOURCES += \
        csound-iOS/classes/bindings/motion/CsoundAccelerometerBinding.m \
        csound-iOS/classes/bindings/motion/CsoundAttitudeBinding.m \
        csound-iOS/classes/bindings/motion/CsoundGyroscopeBinding.m \
        csound-iOS/classes/bindings/motion/CsoundMotion.m \
        csound-iOS/classes/bindings/ui/CsoundButtonBinding.m \
        csound-iOS/classes/bindings/ui/CsoundLabelBinding.m \
        csound-iOS/classes/bindings/ui/CsoundMomentaryButtonBinding.m \
        csound-iOS/classes/bindings/ui/CsoundSliderBinding.m \
        csound-iOS/classes/bindings/ui/CsoundSwitchBinding.m \
        csound-iOS/classes/bindings/ui/CsoundUI.m \
        csound-iOS/classes/midi/CsoundMIDI.m \
        csound-iOS/classes/midi/MidiWidgetsManager.m \
        csound-iOS/classes/midi/SliderMidiWidgetWrapper.m


    INCLUDEPATH += $$PWD/csound-iOS/headers
    INCLUDEPATH += $$PWD/csound-iOS/classes
    INCLUDEPATH += $$PWD/csound-iOS/classes/midi
    LIBS += $$PWD/csound-iOS/libs/libcsound.a
    LIBS += $$PWD/csound-iOS/libs/libsndfile.a
    LIBS += -framework Accelerate
    LIBS += -framework AVFAudio
    LIBS += -framework CoreMidi
    LIBS += -framework CoreMotion
    LIBS += -framework UIKit
    LIBS += -framework MediaPlayer


}


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

message(Includepath: $$INCLUDEPATH Libs: $$LIBS)
