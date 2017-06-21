# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-meijumao


CONFIG += sailfishapp


SOURCES += src/harbour-meijumao.cpp


OTHER_FILES += qml/harbour-meijumao.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-meijumao.spec \
    rpm/harbour-meijumao.yaml \
    rpm/harbour-meijumao.changes \
    harbour-meijumao.desktop \
    qml/pages/BlogDetail.qml \
    qml/pages/Progress.qml \
    qml/py/ \
    qml/pages/About.qml \
    qml/cover/icon.png \
# to disable building translations every time, comment out the
# following CONFIG line

