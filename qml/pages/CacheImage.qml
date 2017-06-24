import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Image{
    id:thumbnail
    asynchronous: true
    property string cacheurl: ""
    fillMode: Image.PreserveAspectFit;
    Python{
        id:imgpy
         Component.onCompleted: {
         addImportPath(Qt.resolvedUrl('../py'));
         imgpy.importModule('main', function () {
                call('main.cacheImg',[cacheurl],function(result){
                    if(!result){
                        thumbnail.source = cacheurl;
                    }else{
                        thumbnail.source = "file:///"+result;
                    }
                     waitingIcon.visible = false;
                });
       })
      }
    }
    Image{
        id:waitingIcon
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/icon-m-refresh";
        //visible: parent.status==Image.Loading
    }
}

