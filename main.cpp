#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QThread>
#include <QQmlContext>
#include "csengine.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Tarmo Johannes Events and Software");
    app.setOrganizationDomain("harmonics.tarmmoj.org");
    app.setApplicationName("Harmonics Practice");


    // move csound into another thread
    QThread  * csoundThread = new QThread();
    CsEngine * cs = new CsEngine();
    cs->moveToThread(csoundThread);

    QObject::connect(csoundThread, &QThread::finished, cs, &CsEngine::deleteLater);
    QObject::connect(csoundThread, &QThread::finished, csoundThread, &QThread::deleteLater);

    QObject::connect(csoundThread, &QThread::started, cs, &CsEngine::play);
    csoundThread->start();



    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("csound", cs); // forward c++ object that can be reached form qml by object name "csound" NB! include <QQmlContext>


    const QUrl url(u"qrc:/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
