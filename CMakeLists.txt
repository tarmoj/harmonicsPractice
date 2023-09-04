cmake_minimum_required(VERSION 3.16)

project(harmonics-practice VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick)

# For Linux: others, see Cabbage example: https://github.com/rorywalsh/cabbage/blob/develop/CMakeLists.txt


# Android build fails....


qt_add_executable(appharmonics-practice
    main.cpp
    csengine.cpp
    resources.qrc
)

qt_add_qml_module(appharmonics-practice
    URI harmonics-practice
    VERSION 1.0
    QML_FILES Main.qml
    QML_FILES HarmonicBox.qml
)

target_link_libraries(appharmonics-practice
    PRIVATE Qt6::Quick
)


if(MSVC)

elseif(APPLE)

elseif(ANDROID)

    target_include_directories(appharmonics-practice PRIVATE
        /home/tarmo/src/csound/Android/CsoundAndroid/jni
    )

    target_sources(appharmonics-practice PUBLIC
        AndroidCsound.hpp
    )



    target_link_libraries(appharmonics-practice PRIVATE
        # Remove: L/home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/
        #Qt::CorePrivate
        c++_shared
        csoundandroid
        sndfile
    )
else()
    include_directories("/usr/local/include/csound")
    find_library(CSOUND_LIBRARY NAMES csound64)

    target_link_libraries(appharmonics-practice
        ${CSOUND_LIBRARY}
    )
endif()


if(ANDROID)
    set_property(TARGET appharmonics-practice APPEND PROPERTY
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
    )
endif()


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appharmonics-practice PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appharmonics-practice
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)



include(GNUInstallDirs)
install(TARGETS appharmonics-practice
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
