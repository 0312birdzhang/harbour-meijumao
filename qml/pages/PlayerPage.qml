import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.0
//import QtQuick.XmlListModel 2.0
import io.thp.pyotherside 1.3
//import QtSystemInfo 5.0
//import Sailfish.Media 1.0

Page {
    id: root

    property int ratio: VideoOutput.PreserveAspectFit

    property string episode: ""
    property string playsource: ""
    property string playtype:""

    orientation: Orientation.Landscape
    allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted

    Component.onCompleted: {
        playpy.playVideo(episode);
    }

    Python{
        id:playpy
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'));
            playpy.importModule('main', function () {
            });
        }
        function playVideo(episode){
            playpy.call('main.play_video',[episode],function(result){
                console.log(result)
                result= eval('(' + result + ')');
                playsource = result.url;
                playtype = result.type;
                console.log(playsource)
                console.log(playtype)
                if(playtype == "origin"){
                    loader.sourceComponent = origin
                }else{
                    loader.sourceComponent = m3u
                }
            })
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        //sourceComponent: playtype == "origin"?origin:m3u
    }

    Component {
        id:m3u
        SilicaFlickable {
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins:  Theme.paddingLarge

                Text {
                    text: Math.ceil(video.bufferProgress * 100)
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    text: video.status === MediaPlayer.Loading ? "影片加载中..." : ( video.status === MediaPlayer.Loaded ? "影片加载中...[完成]": "影片加载中...[完成]" )
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    text: video.status === MediaPlayer.Buffering || video.status === MediaPlayer.Stalled ? "影片缓存中...": ( video.status === MediaPlayer.Buffered ? "影片缓存中...[完成]" : ( video.status === MediaPlayer.Stalled ? "影片缓存中...[错误]" : "" ) )
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    text: video.status === MediaPlayer.InvalidMedia ? "不支持的格式": ( video.status === MediaPlayer.UnknownStatus ? "未知的错误" : "" )
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            Video {
                id: video
                width: parent.width
                height: parent.height
                autoLoad: true
                autoPlay: true
                source: playsource

                onPositionChanged: {
                    if ( video.playbackState === MediaPlayer.PlayingState ) {

                        function indexOfAll(arr, val) {
                            var indexes = []
                            var i = -1
                            while ( ( i = arr.indexOf(val, i + 1 ) ) !== -1 ) {
                                indexes.push(i)
                            }
                            return indexes
                        }


                    }
                }

                Image {
                    source: "image://theme/icon-l-play"
                    height: Theme.iconSizeLarge
                    width: height
                    anchors.centerIn: parent
                    visible: video.playbackState === MediaPlayer.PlayingState ? false : true
                }

                BackgroundItem {
                    anchors.fill: parent
                    onClicked:  {
                        video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
                    }
                    onPressAndHold: Clipboard.text = video.source.toString()
                }
            }

        }
    }
    Component {
        id:origin
        SilicaWebView{
            url:playsource
            anchors.fill:parent
        }
    }
}
