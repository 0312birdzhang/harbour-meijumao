/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page{
    id:showBlogs

    property int operationType: PageStackAction.Animated
    property int page:1
    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted

    Progress{
        id:progress
        parent:showBlogs
        anchors.centerIn: parent
    }

    ListModel {
        id:bloglistModel
    }
 


    function appModel(result){
        console.log(result);
        for ( var i in result){
            bloglistModel.append({
                                    "href":result[i].href,
                                    "article":result[i].article,
                                });

                       }
      view.model  = bloglistModel;
    }
    

    Python{
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            py.importModule('main', function () {
                py.loadBlogs();
             });

        }
        function loadBlogs(){
            progress.running = true;
            py.call('main.bloglist',[],function(result){
                appModel(result);
                progress.running = false;
            });
        }


        onError: {
            //showMsg("加载失败，请刷新重试！")
            progress.visible=false;
        }

    }


    SilicaListView {
        id:view
        header: PageHeader {
            id:header
            title: qsTr("Cnbeta")
        }
        anchors.fill: parent
        PullDownMenu{

            MenuItem{
                text:"关于"
                onClicked:pageStack.push(Qt.resolvedUrl("About.qml"));
            }

        
        }
        PushUpMenu{
            id:pushUp

            MenuItem{
                text:"返回顶部"
                onClicked: view.scrollToTop()
            }

        }

        clip: true
        //spacing:Theme.paddingMedium
        delegate:
            BackgroundItem{
            id:showlist
            height:titleid.height+timeid.height+summaryid.height+Theme.paddingMedium*4
            width: parent.width
            Label{
                id:titleid
                text:article
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font.bold:true;
                anchors {
                    top:parent.top;
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            Label{
                id:summaryid
                text:intro.replace(/(<[\/]?strong>)|(<[\/]?p>)/g,"")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                maximumLineCount: 6
                anchors {
                    top: titleid.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Theme.paddingMedium
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }
            
            Separator {
                visible:(index > 0?true:false)
                width:parent.width;
                //alignment:Qt.AlignHCenter
                color: Theme.highlightColor
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("NewsDetail.qml"),{
                                   "article":article,
                                   "href":href
                               });
            }
        }

        

        VerticalScrollDecorator {flickable: view}

        ViewPlaceholder {
            enabled: view.count == 0 && !PageStatus.Active
            text: "无结果，点击重试"
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    py.loadNews(page)
                }
            }
        }

    }

}
