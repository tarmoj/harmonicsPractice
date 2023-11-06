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


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

message(Includepath: $$INCLUDEPATH Libs: $$LIBS)
