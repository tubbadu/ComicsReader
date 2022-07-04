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

            property var imgs: []
            property int index: 0

            function goRight(amount=1){
                if (index - amount > -1){
                    index -= amount
                } else {
                    index = 0
                }
                img.source = "file://" + imgs[index]
                pageNum.display()
            }

            function goLeft(amount=1){
                if (index + amount < imgs.length){
                    index += amount
                } else {
                    index = imgs.length - 1
                }
                img.source = "file://" + imgs[index]
                pageNum.display()
            }

            function goTo(i){
                index = i
                img.source = "file://" + imgs[index]
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

            function toggleRotate(){
                rotate = !rotate
            }
            DelegateModel {
                id: dioModel
                model: ListModel {}
                delegate: Item{
                    FolderListModel{
                        id: dioFolder
                        property bool loading: (dioFolder.status === FolderListModel.Ready)
                        folder: "file://" + dir
                        showDirs: false
                        showFiles: true
                        nameFilters: [ "*.png", "*.jpg" ]
                        onLoadingChanged: {
                            if(loading){
                                console.log("scanning: " + folder)
                                lView.append(searchFolder.get(searchFolder.ii, "fileName"), "noUrl", root.imgs.length, false)
                                for(let i=0; i<count; i++){
                                    console.log(get(i, "filePath"))
                                    lView.append((searchFolder.ii + 1) + "." + (i + 1), get(i, "filePath"), root.imgs.length, true)
                                    root.imgs.push(get(i, "filePath"))
                                }
                                searchFolder.next()
                            }
                        }
                    }
                }
            }
            ListView{
                model: dioModel
            }

            FolderListModel{
                id: fisrtFolder
                folder: "file:///tmp/comicsReader/"
                showDirs: true
                showFiles: false
                property bool loading: (searchFolder.status === FolderListModel.Ready)

                onLoadingChanged: {
                    console.log("loaded")
                    if(loading){
                        if(count > 0){
                            //multiple chapters
                            searchFolder.folder = "file://" + get(0, "filePath")
                        } else {
                            // single chapter
                            showFiles = true
                            console.log(count)
                            for(let i=0; i<count; i++){
                                console.log(get(i, "filePath"))
                            }
                        }


                    }
                }

            }


            FolderListModel{
                id: searchFolder
                //folder: "file:///tmp/comicsReader/"
                showDirs: true
                showFiles: false
                property int ii: 0
                property bool loading: (searchFolder.status === FolderListModel.Ready)

                onLoadingChanged: {
                    console.log("loaded")
                    if(loading){
                        searchFolder.ii = -1
                        next()
                    }
                }

                function next(){
                    ii++
                    if(ii < count){
                        dioModel.model.append({"dir": get(ii, "filePath")})
                    } else {
                        console.log("we finished!")
                        // display here first image
                        root.index = 0
                        img.source = "file://" + root.imgs[root.index]
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
                            width: parent.width - 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            visible: true
                            z: 1000
                            //y: -height
                            Button{
                                //anchors.left: parent.left
                                id: m10
                                text: "-10"
                                onClicked: {
                                    root.goRight(10)
                                }
                            }
                            RowLayout{
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter // TODO change (it's not perfectly centered)
                                Button{
                                    id: fullscreen
                                    //anchors.right: parent.horizontalCenter
                                    text: "fullscreen"
                                    onClicked: {
                                        root.toggleFullscreen()
                                    }
                                }
                                Button{
                                    id: rotation
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
                                   root.goLeft(10)
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
                            model: ListModel {}
                            delegate: Rectangle{
                                height: pageName.height
                                width: lView.width
                                color: "transparent"
                                Text{
                                    id: pageName
                                    width: parent.width
                                    text: (isFile ? "    page " + name : name)
                                    wrapMode: Text.Wrap
                                    font.pixelSize: 15
                                    color: "white"
                                    style: Text.Outline
                                    styleColor: "black"

                                    MouseArea{
                                        anchors.fill: parent

                                        onClicked: {
                                            root.goTo(pos)
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

                            function append(name, url, pos, isFile=true){ // just a shorter way to do it
                                lModel.model.append({"name": name, "url": url, "pos": pos, "isFile": isFile})
                            }
                        }
                    }
                }

                Text{
                      id: pageNum
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
                        text = (root.index+1) + "/" + root.imgs.length
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

                    Text{
                        id: welcome
                        anchors.horizontalCenter: img.horizontalCenter
                        anchors.verticalCenter: img.verticalCenter
                        textFormat: Text.MarkdownText
                        color: "white"
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                        text: "# Comic Reader fico! \n\n click '**open file**' to select a CBZ or CBR file to read  \nand '**fullscreen**' to enter fullscreen!" // TODO change!
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
                                    root.toggleFullscreen()
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
                                root.goLeft()
                            } else if (x1 - x0 > xThreshold) {
                                root.goRight()
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
