#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>

#ifdef Q_OS_IOS
    #include "csoundproxy.h"
    #include "ios-screen.h"
#else
    #include "csengine.h"
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Tarmo Johannes Events and Software");
    app.setOrganizationDomain("harmonics.tarmmoj.org");
    app.setApplicationName("Harmonics Practice");

#ifdef Q_OS_IOS
    IosScreen screen;
    screen.setTimerDisabled();
    CsoundProxy *cs = new CsoundProxy();
#else
    // move csound into another thread
    QThread *csoundThread = new QThread();
    CsEngine *cs = new CsEngine();
    cs->moveToThread(csoundThread);

    QObject::connect(csoundThread, &QThread::finished, cs, &CsEngine::deleteLater);
    QObject::connect(csoundThread, &QThread::finished, csoundThread, &QThread::deleteLater);

    QObject::connect(csoundThread, &QThread::started, cs, &CsEngine::play);
    csoundThread->start();

#endif



    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "csound",
        cs); // forward c++ object that can be reached form qml by object name "csound" NB! include <QQmlContext>

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

    return app.exec();
}
