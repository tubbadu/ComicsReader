import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.3

Window {
    id: window
    width: 600
    height: 600
    visible: true
    title: qsTr("ComicsReader")
    property bool rotate: false

        Rectangle {
            id: root
            height: (rotate? parent.width : parent.height)
            width: (rotate? parent.height : parent.width)
            color: "black"
            y: (rotate? root.width : 0)
            transform: Rotation{
                angle: (rotate ? -90 : 0)
            }

            function displayFile(){
                log.log("first file is: " + folderModel.get(0, "filePath"))
                img.source = "file://" + folderModel.get(0, "filePath")
                touch.index=0
                log.log("done")
            }

            function toggleRotate(){
                rotate = !rotate
            }

            Timer{
                id: startTimer
                interval: 100
                running: true
                repeat: false
                onTriggered: {
                    root.displayFile()

                }
            }


            FolderListModel{
                id: folderModel
                folder: "file:///tmp/comicsReader/"
                nameFilters: [ "*.png", "*.jpg" ]
                showDirs: false
                Component.onCompleted:{
                    log.log("completed folderModel")

                }
            }



            MultiPointTouchArea {
                id: touch
                property int xThreshold: 100
                property int yThreshold: 200
                property int x0: 0
                property int x1: 0
                property int y0: 0
                property int y1: 0
                property int index: 0

                function goRight(amount=1){
                    if (folderModel.count > 0){
                        // pages loaded
                        if (index - amount > -1){
                            index -= amount
                        } else {
                            index = 0
                        }
                    }
                    log.log(folderModel.get(index, "filePath"))
                    img.source = "file://" + folderModel.get(index, "filePath")
                    pageNum.display()
                }

                function goLeft(amount=1){
                    if (folderModel.count > 0){
                        // pages loaded
                        if (index + amount < folderModel.count){
                            index += amount
                        } else {
                            index = folderModel.count - 1
                        }
                    }
                    log.log(folderModel.get(index, "filePath"))
                    img.source = "file://" + folderModel.get(index, "filePath")
                    pageNum.display()
                }

                function toggleFullscreen(){
                    toolbar.visible = !toolbar.visible
                    if(window.visibility === 5){
                        window.visibility = "Windowed"
                    } else {
                        window.visibility = "FullScreen"
                    }
                }

                anchors.fill: parent
                touchPoints: [
                    TouchPoint { id: point1 }
                ]

                Timer{
                    id: tripleClickTimer

                    property bool tap1: false
                    property bool tap2: false

                    function addTap(){
                        log.log("tapped")
                        start()
                        if(!tap1){
                            tap1 = true
                        } else if(!tap2){
                            tap2 = true
                        } else {
                            // this is the tripleclick!
                            tap1 = false
                            tap2 = false
                            stop()
                            // toggle fullscreen
                            //log.log(window.visibility)
                            touch.toggleFullscreen()
                        }
                    }

                    running: false
                    repeat: false
                    interval: 350 //change perhaps TODO
                    onTriggered:{
                        tap1 = false
                        tap2 = false
                    }
                }

                onPressed: {
                    tripleClickTimer.addTap()

                    x0 = point1.x
                    x1 = point1.x

                    y0 = point1.y
                    y1 = point1.y
                }
                onReleased:{
                    x1 = point1.x
                    y1 = point1.y
                    if (x0 - x1 > xThreshold) {
                        goLeft()
                    } else if (x1 - x0 > xThreshold) {
                        goRight()
                    } else if (y0 - y1 > xThreshold) {
                        log.log("up")
                    } else if (y1 - y0 > xThreshold) {
                        log.log("down")
                    }
                }
            }

            Text{
                id: log
                anchors.fill: parent
                visible: !true
                color: "black"
                z: 99999
                text: "console log here"

                function log(t){
                    text=t+"\n"+text
                }
            }


            /////////////// GUI HERE //////////////////
            Column {
                anchors.fill: parent
                id: gui
                RowLayout {
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.right: parent.right
                    anchors.left: parent.left
                    spacing: 10
                    id: toolbar
                    visible: true
                    z: 1000
                    Button{
                        anchors.left: parent.left
                        id: m10
                        text: "-10"
                        onClicked: {
                            //fileDialog.open()
                            touch.goRight(10)
                        }
                    }
                    RowLayout{
                        spacing: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button{
                            id: fullscreen
                            //anchors.right: parent.horizontalCenter
                            text: "fullscreen"
                            onClicked: {
                                touch.toggleFullscreen()
                            }
                        }
                        Button{
                            id: rotation
                            //anchors.horizontalCenter: parent.horizontalCenter
                            text: "rotate"
                            onClicked: {
                                root.toggleRotate()
                            }
                        }
                    }


                    Button{
                        id: p10
                        anchors.right: parent.right
                        text: "+10"
                        onClicked: {
                            //fileDialog.open()
                           touch.goLeft(10)
                        }
                    }
                    TextArea{
                        id: clip
                        visible: !true
                    }

                }
                Text{
                      id: pageNum
                      anchors.top: ( toolbar.visible ? toolbar.bottom : toolbar.top )
                      anchors.left: parent.left
                      font.pixelSize: 30
                      style: Text.Outline
                      styleColor: "black"
                      visible: false
                      color: "white"
                      z: 100
                      text: "0/0"

                      function display(){
                        text = (touch.index+1) + "/" + folderModel.count
                        visible = true
                        fadeNum.restart()
                      }

                      Timer{
                        id: fadeNum
                        running: false
                        repeat: false
                        interval: 750

                        onTriggered: {
                          pageNum.visible = false
                        }
                      }
                    }
                    Image{
                        id: img
                        anchors.fill: parent

                        fillMode: Image.PreserveAspectFit
                        z: 1
                        //source: "file:///home/tubbadu/Immagini/Screenshot_20220207_222030.png"
                        Component.onCompleted: {
                            //root.displayFile()
                        }

                        Text{
                            id: welcome
                            anchors.horizontalCenter: img.horizontalCenter
                            anchors.verticalCenter: img.verticalCenter
                            textFormat: Text.MarkdownText
                            color: "white"
                            font.pixelSize: 22
                            horizontalAlignment: Text.AlignHCenter
                            text: "# Comic Reader fico! \n\n click '**open file**' to select a CBZ or CBR file to read  \nand '**fullscreen**' to enter fullscreen!"
                            z: -2
                        }
                        BusyIndicator {
                            id: loading
                            anchors.horizontalCenter: img.horizontalCenter
                            anchors.verticalCenter: img.verticalCenter
                            height: 400
                            width: 400
                            running: false //image.status === Image.Loading
                        }
                  }
             }
        }
}
