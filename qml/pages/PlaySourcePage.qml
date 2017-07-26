import QtQuick 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: sourcesPage
    property string episode

    allowedOrientations: Orientation.Portrait

    ListModel{
        id:playSourceModel
    }

    Python{
        id:drawerPy
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            console.log("debug")
            drawerPy.importModule('main', function () {
                console.log("debug1")
                drawerPy.loadPlaysources(episode);
                console.log("debug2")
            });
        }
        function loadPlaysources(episode){
            console.log("start load source"+episode)
            drawerPy.call('main.list_playsource',[episode],function(result){
                console.log(result);
                result = eval('(' + result + ')');
                for(var i = 0;i<result.datas.length;i++){
                    playSourceModel.append({
                                            "href":result.datas[i].href,
                                            "source":result.datas[i].source
                                        });
                }
                playSourceView.model = playSourceModel;
            })
        }
    }

    SilicaListView {
        id:playSourceView
        anchors.fill: parent
        header: PageHeader {
            title: "选择播放源"
        }


        VerticalScrollDecorator {}

        delegate: ListItem {
            id: listItem

            Label {
                x: Theme.horizontalPageMargin
                text: source
                anchors.verticalCenter: parent.verticalCenter
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor

            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("PlayerPage.qml"),{"episode":href})
            }
        }
    }

}
