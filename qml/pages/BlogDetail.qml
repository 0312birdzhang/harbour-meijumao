import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page{
    id:blogDetail
    property string href
	property string article
	property string content
	
    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted


    Python{
        id:detailpy
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            detailpy.importModule('main', function () {
                 detailpy.loadDetail(href)
             });

        }
        function loadDetail(href){
            progress.running = true;
            detailpy.call('main.blogdetail',[href],function(result){
                result= eval('(' + result + ')');
                content = result;
                progress.running = false;
            })
        }

        onError: {
            showMsg("加载失败，请重试！")
            progress.visible=false;
        }


    }
    Progress{
        id:progress
        running: !PageStatus.Active
        parent:blogDetail
        anchors.centerIn: parent
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
            height: detailtime.height+fromMsg.height+contentbody.height+header.height+detaileditor.height+Theme.paddingLarge*5
            Label{
                id:detailtime
                text:{
					var b = href.split("/");
					return "发布时间 : " + b[2] +"-"+b[3]+"-"+b[4]
				}
				
                anchors{
                    left:parent.left
                    right:parent.right
                    margins: Theme.paddingMedium
                }
                horizontalAlignment:Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                truncationMode: TruncationMode.Fade
                wrapMode: Text.WordWrap
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
                anchors{
                    top:detailtime.bottom
                    left:parent.left
                    right:parent.right
                    topMargin: Theme.paddingLarge
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingLarge
                }
                onLinkActivated: {
                    console.log(link)
                    
                }
            }
            
        }
    }


}
