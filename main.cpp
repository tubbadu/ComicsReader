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
#include <unistd.h>

void removeAllTmp(){


    /*// empty directory if already present and full
    QDir dir("/tmp/comicsReader/");
    dir.setNameFilters(QStringList() << "*");
    //dir.setFilter(QDir::Files);

    foreach(QString dirFile, dir.entryList()) // remove all files and empty dir
    {
        dir.remove(dirFile);
        dir.rmdir(dirFile);
    }
    foreach(QString dirFile, dir.entryList()) // remove all subdirectories
    {
        QDir subdir(dirFile);
        subdir.removeRecursively();
    }
    dir.mkdir("/tmp/comicsReader/");*/
}

void unzip(QString arg){
    QProcess p;
    p.start("unzip", QStringList() << arg << "-d" << "/tmp/comicsReader/");
    p.waitForFinished(-1);
    return;
}

void unrar(QString arg){
    /*QProcess p;
    p.start("unrar", QStringList() << "x" << arg << "/tmp/comicsReader/");
    p.waitForFinished(-1);
    return;*/
}

void unpdf(QString arg){
    QProcess p;
    p.start("pdftoppm", QStringList() << "-jpeg" << "-r" << "300" << arg << "/tmp/comicsReader/img");
    p.waitForFinished(-1);
    return;
}
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon("/usr/share/icons/breeze/mimetypes/16/audiobook.svg"));
    QPixmap pixmap("/home/tubbadu/Immagini/Wallpapers/splashscreen.svg");
    QSplashScreen splash(pixmap);
    splash.show();
    app.processEvents();

    QQmlApplicationEngine engine;
    //QString arg(argv[1]);
    QString arg("/home/tubbadu/Video/prova/DV #02 ATGP #01.cbr");
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
        } else if(arg.endsWith(".pdf")) {
            unpdf(arg);
        }else {
            // error
        }
    }


    sleep(1); // don't know why but sometimes it just doesn't load
    // close the loading window
    splash.hide();
    /****** QML HERE ******/ // open the 'real' window

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
