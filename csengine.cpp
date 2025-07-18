#include "csengine.h"
#include <QCoreApplication>
#include <QDebug>
#include <QTemporaryFile>
//#include <QDateTime>

// NB! use DEFINES += USE_DOUBLE -  no, With Csound 6.18 not needed and with Csound 6.12 must be float for Android...

CsEngine::CsEngine(QObject *parent)
    : QObject(parent)
{
    // should be probably in main.cpp
    //csoundInitialize(CSOUNDINIT_NO_ATEXIT | CSOUNDINIT_NO_SIGNAL_HANDLER); // not sure if necessary, but Steven Yi claims, it should be there

#ifdef Q_OS_ANDROID
    cs = new AndroidCsound();
    cs->setOpenSlCallbacks(); // for android audio to work

#else
    cs = new Csound();
#endif
    mStop = false;
    cs->SetOption("-odac");
    cs->SetOption("-d");
}

CsEngine::~CsEngine()
{
    stop(); // this is mess
}

void CsEngine::play()
{
    if (!open(":/harmonicsPractice.csd")) {
        cs->Start();
        //cs->Perform();
        while (cs->PerformKsmps() == 0 && mStop == false) {
            QCoreApplication::
                processEvents(); // probably bad solution but works. Not exactyl necessary, but makes csound/app more responsive
        }

        cs->Stop();
        delete cs;

        qDebug() << "END PERFORMANCE";
        mStop = false; // luba uuesti käivitamine
    }
}

int CsEngine::open(QString csd)
{
    QTemporaryFile *tempFile = QTemporaryFile::createNativeFile(csd); //TODO: checi if not 0

    //qDebug()<<tempFile->fileName() <<  tempFile->readAll();

    if (!cs->Compile(tempFile->fileName().toLocal8Bit().data())) {
        return 0;
    } else {
        qDebug() << "Could not open csound file: " << csd;
        return -1;
    }
}

void CsEngine::stop()
{
    mStop = true;
}

void CsEngine::setChannel(const QString &channel, double value)
{
    //qDebug()<<"setChannel "<<channel<<" value: "<<value;
    cs->SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::readScore(const QString &scoreLine)
{
    // test time:
    //    int time =  QDateTime::currentMSecsSinceEpoch()%1000000;

    qDebug() << "csEvent" << scoreLine; // << time;
    cs->ReadScore(scoreLine.toLocal8Bit());
}

void CsEngine::compileOrc(const QString &code)
{
    cs->CompileOrc(code.toLocal8Bit());
}

void CsEngine::requestChannel(const QString &channel)
{
    if (cs) {
        emit newChannelValue(channel, getChannel(channel));
    }
}

double CsEngine::getChannel(const QString &channel)
{
    if (cs) {
        int error;
        MYFLT value = cs->GetChannel(channel.toLocal8Bit(), &error);
        //qDebug() << "Channel: " << channel << "Error code: " << error << "Value: "  << value; // 0 is OK
        if (!error) {
            return value;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}
