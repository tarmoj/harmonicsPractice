#import "csoundproxy.h"

#import "csound-iOS/classes/CsoundObj.h"

#include <QDebug>
#include <QThread>


extern "C" {
    void csoundMessageCallback(CSOUND *csound, int attr, const char *format, va_list args) {
        char buffer[1024];
        vsnprintf(buffer, sizeof(buffer), format, args);

        // You can filter or route messages based on attr here if needed
        qDebug().noquote() << "[Csound] " << buffer;
    }
}

CsoundProxy::CsoundProxy(QObject *parent)
: QObject(parent)
{
  play(); // probably better to keep the play() code here.

}

CsoundProxy::~CsoundProxy()
{
  stop(); // tryout, probably not the right thing to do

}


void CsoundProxy::play() // starts the performance
{
   CsoundObj *csObj = [[CsoundObj alloc] init];
   cs = (void *)csObj;

    if (!cs) {
        NSLog(@"Failed to initialize CsoundObj");
    } else {
        NSLog(@"CsoundObj initialized: %@", cs);
    }

    NSString *csdFile = [[NSBundle mainBundle] pathForResource:@"harmonicsPractice" ofType:@"csd"];
        NSLog(@"Csound FILE PATH: %@", csdFile);

    [(CsoundObj *)cs play:csdFile];

    csound = nullptr;

    const int maxAttempts = 100; // 100 × 10ms = 1 second
    int attempts = 0;
    while (attempts++ < maxAttempts) {
        csound = [(CsoundObj *)cs getCsound];
        if (csound != nullptr) {
            csoundSetMessageCallback(csound, csoundMessageCallback);
            break;
        }
        QThread::msleep(10);
    }

    if (csound) {
        qDebug() << "Csound is ready:" << csound << "in " << attempts*10 << " ms";
    } else {
        qWarning() << "Timeout: Csound did not initialize in time.";
    }
       
}

void CsoundProxy::readScore(const QString &scoreLine)
{
    if (csound) {
        csoundInputMessage(csound, scoreLine.toLocal8Bit());
    }
}

void CsoundProxy::setChannel(QString channel, double value)
{
    if (csound) {
        qDebug() << "Channel: " << channel << " value: " << value;
        csoundSetControlChannel(csound, channel.toUtf8().constData(), value) ;

    } else {
        qDebug() << "Csound is null";
    }
}

void CsoundProxy::compileOrc(const QString &code)
{
  if (csound) {
    csoundCompileOrc(csound,  code.toUtf8().constData());
    } else {
        qDebug() << "Csound is null";
    }
}


void CsoundProxy::stop()
{
  if (csound) {
    csoundStop(csound);
    csoundCleanup(csound); // not sure if needed
    csoundDestroy(csound);
    csound = nullptr;
    cs = nullptr;
  }
}

void CsoundProxy::requestChannel(const QString &channel)
{
    if (csound) {
        emit newChannelValue(channel, getChannel(channel));
    }
}

double CsoundProxy::getChannel(const QString &channel)
{
    if (csound) {
        int error;
        MYFLT value = csoundGetControlChannel(csound, channel.toUtf8().constData(), &error);
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


