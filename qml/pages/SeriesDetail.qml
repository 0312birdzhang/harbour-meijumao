import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page{
    id:blogDetail
    property string series
	property string article
    property string thumbnail
    property string content
	
    allowedOrientations: Orientation.Landscape //| Orientation.Portrait | Orientation.LandscapeInverted


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
            detailpy.call('main.list_sections',[series],function(result){
                result= eval('(' + result + ')');
                content = result.fancy;
            })
        }
    }


    SilicaFlickable {
        id:view
        visible: PageStatus.Active
        PageHeader {
            id:header
            title: article
            _titleItem.font.pixelSize: Theme.fontSizeSmall
        }

        anchors.fill: parent
        contentHeight: detail.height

        Item{
            id:detail
            y:header.height
            width:blogDetail.width
            height: contentbody.height+header.height+sections.height+Theme.paddingLarge

            Label{
                id:contentbody
                opacity: 0.8
                textFormat: Text.RichText
                text:content
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    top:detailtime.bottom
                    left:parent.left
                    right:parent.right
                    topMargin: Theme.paddingLarge
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                    bottomMargin: Theme.paddingLarge
                }

            }

            SilicaListView{
                id:sections
                anchors{
                    top:contentbody.bottom
                    margins: Theme.paddingMedium
                }
                model: sectionModel
                clip: true
                delegate:BackgroundItem{
                    width: parent.width
                    height: catelabelid.height + Theme.paddingMedium * 2
                    Label{
                        id:catelabelid
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
                    Image {
                        id: iconLeftImg

                        anchors {
                            right: parent.right
                            rightMargin: Theme.paddingSmall
                            verticalCenter: parent.verticalCenter
                        }
                        source: "image://theme/icon-m-right"
                    }
                    onClicked: {
                        headtitle = "分类-"+label
                        py.loadSections(section);
                        view.scrollToTop()
                        pageStack.popAttached(undefined);
                    }
                }
            }
            
        }
    }


}
