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
    id:firstPage

    property int operationType: PageStackAction.Animated
    property int page:1
    property string headtitle: "推荐"
    property string current_section: "/maogetvs"
    property bool nextpage:false
    property bool prevpage:false
    property string next_section
    property string pre_section
    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted


    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (pageStack._currentContainer.attachedContainer == null) {
                pageStack.pushAttached(categoriesPage)
            }
        }
    }

    ListModel {
        id:meijulistModel
    }
 


    function appModel(result){
        meijulistModel.clear();
        if(!result){
            return;
        }
        for ( var i = 0 ; i< result.datas.length ; i++){
            meijulistModel.append({
                                      "series":result.datas[i].href,
                                      "article":result.datas[i].label,
                                      "thumbnail":result.datas[i].thumbnail
                                  });

        }
        nextpage = result.next_page
        prevpage = result.pre_page
        if(nextpage)next_section = result.next_section
        if(prevpage)pre_section = result.pre_section
        view.model  = meijulistModel;
    }
    


    /*

    ("/search", u"搜索"),
    ("/categories", u"分类"),
    ("/maogetvs", u"猫哥推荐"),
    ("/alltvs", u"所有美剧"),
    ("/populartvs", u"热门美剧"),
    ("/sitemaptvs",u"美剧索引")
    */

    Python{
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            py.importModule('main', function () {
                py.loadSections(current_section);
//                py.loadCategories(current_section);
             });

        }




        //推荐、热门、所有等等
        function loadSections(section){
            current_section = section;
            py.call('main.list_sections',[section],function(result){
                console.log(result)
                appModel(eval('(' + result + ')'));
            });
        }


    }


    SilicaGridView {
        id:view
        header: PageHeader {
            id:header
            title: headtitle
        }
        anchors.fill: parent
        PullDownMenu{
            id:pullDownMenu
            MenuItem{
                text:"所有"
                onClicked: {
                    headtitle = text
                    py.loadSections("/alltvs");
                }
            }

            MenuItem{
                text:"推荐"
                onClicked: {
                    headtitle = text
                    py.loadSections("/maogetvs");
                }
            }

            MenuItem{
                text:"热门"
                onClicked: {
                    headtitle = text
                    py.loadSections("/populartvs");
                }
            }
            MenuItem{
                text:"关于"
                onClicked:pageStack.push(Qt.resolvedUrl("About.qml"));
            }


        
        }

//        model : meijulistModel
        clip: true
        width: childrenRect.width
        currentIndex: -1
        cellWidth: view.width / 3
        cellHeight: Screen.height / 2.5
        cacheBuffer: 2000;
        delegate:
            BackgroundItem{
            id:showlist
            width: (parent.width - Theme.paddingMedium ) / 3
            height: titleid.height + thumb.height + Theme.paddingSmall * 2

            Label{
                id:titleid
                text:article
                truncationMode: TruncationMode.Elide
                maximumLineCount: 3
                width: parent.width
                height: Theme.itemSizeSmall
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font {
                   pixelSize: Theme.fontSizeMedium
                   family: Theme.fontFamilyHeading
                   bold:true;
               }
            }

            CacheImage{
                id:thumb
                cacheurl :thumbnail
                fillMode: Image.PreserveAspectFit;
                anchors {
                    top: titleid.bottom
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }
            

            onClicked: {
                pageStack.push(Qt.resolvedUrl("NewsDetail.qml"),{
                                   "article":article,
                                   "href":href
                               });
            }
        }

        
        footer: Component{

            Item {
                id: loadMoreID
                visible: !appwindow.loading
                anchors {
                    left: parent.left;
                    right: parent.right;
                }
                height: Theme.itemSizeMedium
                Row {
                    id:footItem
                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button {
                        text: "上一页"
                        visible: prevpage
                        onClicked: {
                            view.scrollToTop()
                            py.loadSections(pre_section);
                        }
                    }
                    Button{
                        text:"下一页"
                        visible: nextpage
                        onClicked: {
                           view.scrollToTop()
                           py.loadSections(next_section);
                        }
                    }
                }
            }

        }

        VerticalScrollDecorator {flickable: view}

        ViewPlaceholder {
            enabled: view.count == 0 && !appwindow.loading && !PageStatus.Active
            text: "无结果，点击重试"
            MouseArea{
                anchors.fill: parent
                onClicked: {
                     py.loadSections(current_section);
                }
            }
        }

    }


    Component {
        id: categoriesPage
        Page {
            ListModel{
                id:categoriesModel
            }
            function loadCategories(article){
                py.call('main.list_categories',[article],function(result){
//                    console.log(result)
                    fillCategory(result);
                });
            }
            function fillCategory(result){
                categoriesModel.clear();
                if(result.length == 0)return;
                for(var i=0;i<result.length;i++){
//                    console.log(result[i].label)
                    categoriesModel.append({
                                               "section":result[i].section,
                                               "label":result[i].label
                                           })
                }
                cateView.model = categoriesModel
            }

            Component.onCompleted: {
                loadCategories("/alltvs")
            }

            SilicaListView {
                id:cateView
                header: PageHeader {
                    id:header
                    title: "分类"
                }
                anchors.fill: parent
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
