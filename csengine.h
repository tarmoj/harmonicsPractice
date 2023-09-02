#ifndef CSENGINE_H
#define CSENGINE_H
#include <QObject>

#ifdef Q_OS_ANDROID
    #include "AndroidCsound.hpp"
#else
    #include <csound.hpp>
#endif


class CsEngine : public QObject
{
    Q_OBJECT

public:

	explicit CsEngine(QObject *parent = 0);
	~CsEngine();


	void play();
	int open(QString csd);

public slots:

    Q_INVOKABLE void stop();
    void setChannel(const QString &channel, double value);
    void readScore(const QString &event);
    void compileOrc(const QString &code);

	//Q_INVOKABLE double getChannel(const char *channel);

private:
    bool mStop;
#ifdef Q_OS_ANDROID
	AndroidCsound * cs;
#else
	Csound * cs;
#endif


};

#endif // CSENGINE_H
