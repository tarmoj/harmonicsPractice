#include "csengine.h"
#include <QDebug>
#include <QTemporaryFile>
#include <QCoreApplication>
//#include <QDateTime>

// NB! use DEFINES += USE_DOUBLE


CsEngine::CsEngine(QObject *parent) : QObject(parent)
{

    // should be probably in main.cpp
    //csoundInitialize(CSOUNDINIT_NO_ATEXIT | CSOUNDINIT_NO_SIGNAL_HANDLER); // not sure if necessary, but Steven Yi claims, it should be there

#ifdef Q_OS_ANDROID
	cs = new AndroidCsound();
	cs->setOpenSlCallbacks(); // for android audio to work
    cs->SetOption("--env:SSDIR=/sdcard/Music/Bourdon/samples/");

# else
	cs = new Csound();
    cs->SetOption("--env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/");
#endif
    mStop=false;
	cs->SetOption("-odac");
	cs->SetOption("-d");
}

CsEngine::~CsEngine()
{
	stop(); // this is mess
}

void CsEngine::play() {

    if (!open(":/bourdon.csd")) {
		cs->Start();
        //cs->Perform();
		while(cs->PerformKsmps()==0 && mStop==false ) {
            QCoreApplication::processEvents(); // probably bad solution but works. Not exactyl necessary, but makes csound/app more responsive
		}

        cs->Stop();
        delete cs;

		qDebug()<<"END PERFORMANCE";
		mStop=false; // luba uuesti käivitamine
	}
}

int CsEngine::open(QString csd)
{

    QTemporaryFile *tempFile = QTemporaryFile::createNativeFile(csd); //TODO: checi if not 0

    //qDebug()<<tempFile->fileName() <<  tempFile->readAll();

	if (!cs->Compile( tempFile->fileName().toLocal8Bit().data()) ){
        return 0;
    } else {
        qDebug()<<"Could not open csound file: "<<csd;
        return -1;
    }
}

void CsEngine::stop()
{
	mStop = true;
}


void CsEngine::setChannel(const QString &channel, MYFLT value)
{
    qDebug()<<"setChannel "<<channel<<" value: "<<value;
    cs->SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::readScore(const QString &scoreLine)
{
    // test time:
//    int time =  QDateTime::currentMSecsSinceEpoch()%1000000;

    qDebug()<<"csEvent" << scoreLine ; // << time;
    cs->ReadScore(scoreLine.toLocal8Bit());
}

void CsEngine::compileOrc(const QString &code)
{
	cs->CompileOrc(code.toLocal8Bit());
}
