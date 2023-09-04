lessThan(QT_MAJOR_VERSION,6): error("Qt6 is required for this build.")

QT += quick core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
        csengine.cpp

HEADERS += \
    csengine.h

RESOURCES += resources.qrc

INCLUDEPATH += /usr/local/include/csound/


android {
  #QT += core-private
  INCLUDEPATH += /home/tarmo/src/csound/Android/CsoundAndroid/jni/	 #TODO: should have an extra varaible, not hardcoded personal library
  HEADERS += AndroidCsound.hpp
  LIBS +=  -L/home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/ -lcsoundandroid -lsndfile -lc++_shared
}

linux:!android {
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

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_EXTRA_LIBS = \
        /home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/libsndfile.so \
        /home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/libcsoundandroid.so \
        /home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/libc++_shared.so
}
