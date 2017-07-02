import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page{
    id:blogDetail
    property string series
    property string article
    property string thumbnail
    property string content

    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted


    ListModel{
        id:sectionModel
    }

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
                result= eval('(' + result + ')');
                content = result.fancy;
//                console.log(content);
//                console.log(result.datas)
                for(var i = 0;i<result.datas;i++){
                    sectionModel.append({
                                            "label":result.datas[i].label,
                                            "episode":result.datas[i].episode
                                        });
                }
//                sections.model = sectionModel
            })
        }
    }

    PageHeader {
        id:header
        title: article
    }


    SilicaFlickable {
        id:flick
        width: parent.width
        anchors{
            left:parent.left
            right: parent.right
            top:header.bottom
        }
        contentHeight: detail.height
        contentWidth: parent.width
        VerticalScrollDecorator { flickable: flick }
        Column{
            id:detail
            spacing: Theme.paddingMedium
            anchors{
                left:parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
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
                text:content.replace("\<h2\>剧情简介:\<\/h2\>","")
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                width: Screen.width - Theme.paddingMedium

            }
            SectionHeader {
                text: "剧集"
            }
            Item{

                GridView{
                id:sections
                anchors.fill: parent
                cellWidth:100;
                cellHeight:60;
                model:7
                anchors.top:contentbody.bottom
                delegate:BackgroundItem{
                    width: parent.width
                    height: catelabelid.height + Theme.paddingMedium * 2
                    Label{
                        id:catelabelid
                        text:"test"
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
                    }
                }
            }

            }

        }
    }


}
