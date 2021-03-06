import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page{
    id:page
    property string series
    property string article
    property string thumbnail
    property string content

    allowedOrientations: Orientation.Portrait //| Orientation.Landscape | Orientation.LandscapeInverted


    ListModel{
        id:sectionModel
    }



    SilicaFlickable {
        id:flick

        Python{
            id:detailpy
            Component.onCompleted: {
                addImportPath(Qt.resolvedUrl('../py'));
                detailpy.importModule('main', function () {
                    detailpy.loadDetail(series)
                });

            }
            function loadDetail(series){
                detailpy.call('main.list_series',[series],function(result){
                    console.log(result)
                    result= eval('(' + result + ')');
                    content = result.fancy;
                    for(var i = 0;i<result.datas.length;i++){
                        sectionModel.append({
                                                "label":result.datas[i].label,
                                                "episode":result.datas[i].episode
                                            });
                    }
                    sections.model = sectionModel;
//                    console.log(sectionModel.count);
                })
            }
        }
        width: parent.width
        anchors.fill: parent
        contentHeight: detail.height + sections.height
        contentWidth: parent.width

        Column{
            id:detail
            spacing: Theme.paddingMedium
            anchors{
                left:parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }

            PageHeader {
                id:header
                title: article
            }
            //            CacheImage{
            //                id:thumb
            //                cacheurl :thumbnail
            //                width: Screen.width / 2.5
            //                fillMode: Image.PreserveAspectFit;
            //            }
            SectionHeader {
                text: "剧情简介"
            }
            Label{
                id:contentbody
                opacity: 0.8
                textFormat: Text.RichText
                text:content
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                width: Screen.width - Theme.paddingMedium

            }
            SectionHeader {
                text: "剧集"
            }
        }

        SilicaGridView{
            id:sections
            anchors{
                top:detail.bottom
                left:parent.left
                right: parent.right
            }
            width: parent.width
            height: childrenRect.height
            cellWidth:parent.width/4;
            cellHeight:Theme.itemSizeSmall;
            clip: true
            currentIndex: -1
            delegate:BackgroundItem{
                width: sections.cellWidth;
                height: Theme.itemSizeSmall;
                Label{
                    text:label
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    font.bold:true;
                    anchors {
                        top:parent.top;
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingMedium
                    }
                }
                onClicked: {
                    if(episode.indexOf("http") > -1){
                        //第三方资源
                        remorse.execute("正在打开浏览器...", function(){
                             Qt.openUrlExternally(episode)
                        })
                    }else{
                        //选择播放源
                        pageStack.push(Qt.resolvedUrl("PlaySourcePage.qml"),{"episode":episode})
                        
                    }
                }
                onPressAndHold:{
                    remorse.execute("正在打开浏览器...", function(){
                             Qt.openUrlExternally(meijumao+episode)
                    })
                }
            }
            VerticalScrollDecorator {}

     }
        VerticalScrollDecorator {flickable: flick}
    }



}
