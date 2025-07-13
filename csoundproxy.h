#ifndef CSOUNDPROXY_H
#define CSOUNDPROXY_H

#include <QObject>
#include <csound.h>

class CsoundProxy : public QObject
{
    Q_OBJECT
public:
    explicit CsoundProxy(QObject *parent = nullptr);
    ~CsoundProxy();

    Q_INVOKABLE void play();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void readScore(const QString &scoreLine);
    Q_INVOKABLE void setChannel(QString channel, double value);


    Q_INVOKABLE void compileOrc(const QString &code);

    Q_INVOKABLE double getChannel(const QString &channel);

    Q_INVOKABLE void requestChannel(const QString &channel); // value will be returned via signal newChannelValue


signals:
    void newChannelValue(QString channel, double value);
    

private:
    void *cs; // CsoundObj will be pointed here. Cannot import Objective C CsoundObj here
    CSOUND *csound;
};

#endif // CSOUNDPROXY_H


