#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>

#ifdef Q_OS_IOS
#include "csoundproxy.h"
#include "ios-screen.h"
#else
//    #include "csengine.h"
#endif

#ifdef Q_OS_ANDROID
#include <QJniEnvironment>
#include <QtCore/private/qandroidextras_p.h>

#endif


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Tarmo Johannes Events and Software");
    app.setOrganizationDomain("harmonics.tarmoj.org");
    app.setApplicationName("Harmonics Practice");

#ifdef Q_OS_ANDROID

    //keep screen on:
    QJniObject activity
        = QNativeInterface::QAndroidApplication::context(); //  QtAndroid::androidActivity();
    if (activity.isValid()) {
        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

        if (window.isValid()) {
            const int FLAG_KEEP_SCREEN_ON = 128;
            window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);


            // set titlebar color here...
            int androidVersion = QNativeInterface::QAndroidApplication::sdkVersion();
            qDebug() << "Android version: " << androidVersion;
            if (androidVersion <= 34) { // Android 14 and below
                window.callMethod<void>("addFlags", "(I)V", 0x80000000);
                window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
                window.callMethod<void>(
                    "setStatusBarColor",
                    "(I)V",
                    0x1c1b1f); // hardcoded color for now. later try to get via QML engine Material.background
                QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
                decorView.callMethod<void>("setSystemUiVisibility", "(I)V", 0x00002000);
            }
        }

        QJniEnvironment env;
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
        } //Clear any possible pending exceptions.
    }
#endif


#ifdef Q_OS_IOS
    IosScreen screen;
    screen.setTimerDisabled();
    CsoundProxy *cs = new CsoundProxy();
#else
    // move csound into another thread
    // QThread *csoundThread = new QThread();
    // CsEngine *cs = new CsEngine();
    // cs->moveToThread(csoundThread);

    // QObject::connect(csoundThread, &QThread::finished, cs, &CsEngine::deleteLater);
    // QObject::connect(csoundThread, &QThread::finished, csoundThread, &QThread::deleteLater);

    // QObject::connect(csoundThread, &QThread::started, cs, &CsEngine::play);
    // csoundThread->start();

#endif

    QQmlApplicationEngine engine;

    /*engine.rootContext()->setContextProperty(
        "csound",
        cs);*/ // forward c++ object that can be reached form qml by object name "csound" NB! include <QQmlContext>

    const QUrl url(u"qrc:/Main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    QObject *qmlApp = engine.rootObjects().first();
/*
    QObject::connect(qmlApp,
                     SIGNAL(setChannel(QString, double)),
                     cs,
                     SLOT(setChannel(QString, double)));
    QObject::connect(qmlApp, SIGNAL(readScore(QString)), cs, SLOT(readScore(QString)));
    QObject::connect(qmlApp, SIGNAL(compileOrc(QString)), cs, SLOT(compileOrc(QString)));

    QObject::connect(qmlApp, SIGNAL(requestChannel(QString)), cs, SLOT(requestChannel(QString)));
    QObject::connect(cs,
                     SIGNAL(newChannelValue(QString, double)),
                     qmlApp,
                     SIGNAL(newChannelValue(
                         QString,
                         double))); // connect signal to siganl to allow multithread connection
*/
    return app.exec();
}
