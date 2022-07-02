#include <QQmlApplicationEngine>
#include <QApplication>
#include <QPushButton>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QSplashScreen>
#include <QProgressDialog>
#include <QProcess>
#include <QWindow>
#include <QString>
#include <QLabel>
#include <QImage>
#include <QFile>
#include <QDir>

void removeAllTmp(){
    QDir dir("/tmp/comicsReader/");
    dir.setNameFilters(QStringList() << "*");
    dir.setFilter(QDir::Files);
    foreach(QString dirFile, dir.entryList())
    {
        dir.remove(dirFile);
    }
}

void unzip(QString arg){
    QProcess p;
    p.start("unzip", QStringList() << arg << "-d" << "/tmp/comicsReader/");
    p.waitForFinished(-1);
    return;
}

void unrar(QString arg){
    QProcess p;
    p.start("unrar", QStringList() << "e" << arg << "/tmp/comicsReader/");
    p.waitForFinished(-1);
    return;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QPixmap pixmap("/home/tubbadu/Immagini/Screenshot_20220207_222030.png");
    QSplashScreen *splash = new QSplashScreen();
    splash->show();

    QQmlApplicationEngine engine;
    QString arg(argv[1]);
    QFile file(arg);
    QString cmd;



    //bool exists = QFile::exists("/home/pw/docs/file.txt");
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)){
    } else {
        removeAllTmp();
        if(arg.endsWith(".cbz")){
            // unzip
            unzip(arg);
        } else if(arg.endsWith(".cbr")){
            // unrar
            unrar(arg);
        } else {
            // error
        }
    }



    // close the loadin window
    //loading.hide();
    /****** QML HERE ******/ // open the 'real' window

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
    /**********************/
    //
    //return a.exec();
}



/*
#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
*/
