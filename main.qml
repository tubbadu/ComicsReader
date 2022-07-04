import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.3
import QtQml.Models 2.2

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
                    root.displayFile() // used to allow to load every file (don't know why onCompleted wasn't enough)
                    for(let i=0; i<folderModel.count; i++){
                        lView.append(i+1, folderModel.get(i, "filePath"))
                    }
                }
            }

            FolderListModel{
                id: folderModel
                folder: "file:///tmp/comicsReader/"
                //nameFilters: [ "*.png", "*.jpg" ]
                showDirs: true
                showFiles: false
                Component.onCompleted:{
                    log.log("completed folderModel")
                }
                property var subdir: []
                function getPaths(){
                    folder = "file:///tmp/comicsReader/"
                    showDirs = true
                    showFiles = false
                    
                    for(let i=0; i<count; i++){
                        subdir.append({"dir": get(i, "filePath")})
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
            Item {
                anchors.fill: parent
                id: gui
                Item{
                    id: topItem
                    anchors.fill: parent
                    MultiPointTouchArea{
                        id: touchTopbar
                        width: parent.width
                        height: 20
                        y: 0
                        //anchors.top: gui.top
                        touchPoints: [
                            TouchPoint { id: p }
                        ]

                        onReleased: {
                            if(topbar.y < 0){
                                topbar.y = - topbar.height // close
                                // TODO add animation
                            } else {
                                topbar.y = 0
                            }
                            touchTopbar.y = topbar.y + topbar.height - touchTopbar.height/2
                        }
                        onUpdated: {
                            if(p.y - topbar.height + touchTopbar.y < 0){
                                topbar.y = p.y - topbar.height + touchTopbar.y
                            } else {
                                topbar.y = 0
                            }
                        }
                    }
                    Rectangle{
                        id: topbar
                        color: "white"
                        width: parent.width
                        height: toolbar.height + 10
                        y: -height
                        z: 100
                        Component.onCompleted: {
                            color.a = 0.1

                            // open topbar
                            topbar.y = 0
                            touchTopbar.y = topbar.y + topbar.height - touchTopbar.height/2
                        }


                        RowLayout {
                            id: toolbar
                            //anchors.right: parent.right
                            //anchors.left: parent.left
                            width: parent.width - 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            visible: true
                            z: 1000
                            //y: -height
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
                    }
                }

                Item{
                    id: leftItem
                    height: parent.height
                    y: touchTopbar.y + touchTopbar.height / 2 // TODO make it move with the topbar
                    MultiPointTouchArea{
                        id: touchLeftbar
                        width: 20
                        height: parent.height
                        y: 0
                        //anchors.top: gui.top
                        touchPoints: [
                            TouchPoint { id: p2 }
                        ]

                        onReleased: {
                            if(leftbar.x < 0){
                                leftbar.x = - leftbar.width // close
                                // TODO add animation
                            } else {
                                leftbar.x = 0
                            }
                            touchLeftbar.x = leftbar.x + leftbar.width - touchLeftbar.width/2
                        }
                        onUpdated: {
                            if(p2.x - leftbar.width + touchLeftbar.x < 0){
                                leftbar.x = p2.x - leftbar.width + touchLeftbar.x
                            } else {
                                leftbar.x = 0
                            }
                        }
                    }
                    Rectangle{
                        id: leftbar
                        color: "white"
                        width: 200 //parent.width
                        height: parent.height //toolbar.height + 10
                        x: -width
                        z: 100
                        Component.onCompleted: {
                            color.a = 0.1

                            // open topbar
                            leftbar.x = 0
                            touchLeftbar.x = leftbar.x + leftbar.width - touchLeftbar.width/2
                        }


                        DelegateModel {
                            id: lModel
                            model: ListModel {
                                /*ListElement { name: "Apple"; url: "/home/tubbadu/Immagini/Screenshot_20220207_222030.png" }
                                ListElement { name: "Orange"; url: "/home/tubbadu/Immagini/Screenshot_20220207_222030.png" }*/
                            }
                            delegate: Rectangle{
                                height: pageName.height
                                width: lView.width
                                color: "transparent"
                                Text{
                                    id: pageName
                                    text: "    page " + name
                                    font.pixelSize: 15
                                    color: "white"
                                    style: Text.Outline
                                    styleColor: "black"

                                    MouseArea{
                                        anchors.fill: parent

                                        onClicked: {
                                            touch.goTo(name - 1)
                                        }
                                    }
                                }
                            }
                        }
                        ListView{
                            id: lView
                            model: lModel
                            anchors.bottom: parent.bottom
                            height: parent.height - 10
                            width: parent.width - 10

                            function append(name, url){
                                lModel.model.append({"name": name, "url": url})
                            }

                            Component.onCompleted: {
                                //lModel.model.append({"name": "pippo", "url": "/home/tubbadu/Immagini/Screenshot_20220207_222030.png"})
                            }
                        }
                    }
                }

                Text{
                      id: pageNum
                      //anchors.top: toolbar.bottom
                      anchors.right: parent.right
                      font.pixelSize: 30
                      style: Text.Outline
                      styleColor: "black"
                      visible: false
                      color: "white"
                      z: 100
                      y: topbar.y + topbar.height// + 10
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
                    z: -1
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

                    MultiPointTouchArea {
                        id: touch
                        property int xThreshold: 100
                        property int yThreshold: 200
                        property int x0: 0
                        property int x1: 0
                        property int y0: 0
                        property int y1: 0
                        property int index: 0
                        anchors.fill: parent
                        touchPoints: [
                            TouchPoint { id: point1 }
                        ]

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

                        function goTo(i){
                            index = i
                            log.log(folderModel.get(index, "filePath"))
                            img.source = "file://" + folderModel.get(index, "filePath")
                            pageNum.display()
                        }

                        function toggleFullscreen(){
                            //toolbar.visible = !toolbar.visible

                            if(window.visibility === 5){
                                window.visibility = "Windowed"
                                // open topbar
                                topbar.y = 0
                                touchTopbar.y = topbar.y + topbar.height - touchTopbar.height/2
                                // open leftbar
                                leftbar.x = 0
                                touchLeftbar.x = leftbar.x + leftbar.width - touchLeftbar.width/2
                            } else {
                                window.visibility = "FullScreen"
                                // close topbar
                                topbar.y = -topbar.height
                                touchTopbar.y = topbar.y + topbar.height - touchTopbar.height/2
                                // close leftbar
                                leftbar.x = - leftbar.width
                                touchLeftbar.x = leftbar.x + leftbar.width - touchLeftbar.width/2
                            }
                        }

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
              }
        }
    }
}
