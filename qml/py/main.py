import sys,os
import urllib.request
import urllib.parse
import pyotherside
import json
from basedir import *
from bs4 import BeautifulSoup
import logging

target=HOME+"/Downloads/"
__AUTHOR__ = "BirdZhang"

_meijumao = "http://www.meijumao.net"
__index__ = [
    ("/search", u"搜索"),
    ("/categories", u"分类"),
    ("/maogetvs", u"猫哥推荐"),
    ("/alltvs", u"所有美剧"),
    ("/populartvs", u"热门美剧"),
    ("/sitemaptvs",u"美剧索引")
]


def index():
    return __index__

# get categories
def list_categories(article):
    html = get(_meijumao + article)
    soup = BeautifulSoup(html, "html5lib")
    listing = []
    for urls in soup.find_all("a", attrs={"data-remote": "true"}):
        listing.append({
           "action" : "list_sections",
           "section": urls.get("href").replace(_meijumao, "")
           "label" : urls.div.get_text()

    })
    return listing



# get sections
def list_sections(section):
    if section == "#":
        return
    html = get(_meijumao + section)
    soup = BeautifulSoup(html, "html5lib")

    will_page = soup.find("ul", attrs={"id": "will_page"})
    if will_page:
        pass
    listing = []
    sections_map = {}
    for section in soup.find_all("article"):
        listing.append({
                    "label":section.div.a.img.get("alt"),
                    "thumbnailImage":section.div.a.img.get("src"),
                    "action":"list_series",
                    "series":section.div.a.get("href")
            })
    sections_map["datas"] = listing
    # pagination
    will_page = soup.find("ul", attrs={"id": "will_page"}).find_all("li")
    if len(will_page) > 0:
        if will_page[0].find("a").get("href") != "#":
            sections_map["next_page"] = True
            sections_map["next_section"] = will_page[0].find("a").get("href")

        if will_page[-1].find("a").get("href") != "#":
            sections_map["pre_page"] = True
            sections_map["pre_section"] = will_page[-1].find("a").get("href")
        
    return json.loads(sections_map)


#def list_series(series, seriesname, fanart_image):
#    html = get(_meijumao + series)
#    soup_series = BeautifulSoup(html, "html5lib")

#    listing = []
#    for serie in soup_series.find_all(
#            "div", attrs={
#            "class": "col-lg-1 col-md-2 col-sm-4 col-xs-4"}):
#        if not serie.a:
#            continue
#        list_item = xbmcgui.ListItem(
#            label=serie.a.get_text().replace(
#                " ", "").replace(
#                "\n", ""))
#        if not serie.a.get("href").startswith("/"):
#            continue
#        url = '{0}?action=play_video&episode={1}&name={2}'.format(
#            _url,
#            serie.a.get("href"),
#            "[COLOR green]" +
#            seriesname +
#            "[/COLOR] [COLOR yellow]" +
#            serie.a.get_text().replace(
#                " ",
#                "").replace(
#                "\n",
#                "").encode("utf-8") +
#            "[/COLOR]")
#        is_folder = False
#        listing.append((url, list_item, is_folder))

#    xbmcplugin.addDirectoryItems(_handle, listing, len(listing))
#    xbmcplugin.endOfDirectory(_handle)


#def list_playsource(episode, name):
#    html = get(_meijumao + episode)
#    soup_source = BeautifulSoup(html, "html5lib")
#    listing = []
#    for source in soup_source.find_all(
#            "a", attrs={
#            "class": "button button-small button-rounded"}):
#        list_item = xbmcgui.ListItem(label=source.get_text())
#        if source.get("href").startswith("http"):
#            continue
#        # url = '{0}?action=play_video&episode={1}&name={2}'.format(_url, source.get("href"),name)
#        listing.append((source.get("href"), name))
#    if len(listing) == 0:
#        dialog.ok(__addonname__, '没有找到视频源')
#        return
#    else:
#        play_video(listing[0])


#def play_video(episode, name):
#    """
#    Play a video by the provided path.
#    :param path: str
#    :return: None
#    """
#    episode = episode.replace("show_episode?", "play_episode?")
#    html = get(_meijumao + episode)
#    if not html:
#        dialog.ok(__addonname__, '没有找到视频源，播放出错')
#        return
#    soup_js = BeautifulSoup(html, "html5lib")
#    title = ""
#    if soup_js.find_all("h1"):
#        title = soup_js.find_all("h1")[0].get_text()
#    if soup_js.find_all("li", attrs={"class": "active"}):
#        title += " - " + soup_js.find_all("li",
#                                          attrs={"class": "active"})[0].get_text()
#    play_url = ""
#    for script in soup_js.find_all('script'):
#        matched = re.search('http.*m3u8.*\"', script.get_text())
#        if matched:
#            play_url = matched.group().replace(
#                "\"",
#                "").replace(
#                "&amp;",
#                "&").replace(
#                "->application/x-mpegURL",
#                "")
#    if len(play_url) == 0:
#        dialog.ok(__addonname__, '没有找到视频源，播放出错')
#        return
#    play_item = xbmcgui.ListItem(name)
#    play_item.setInfo(type="Video", infoLabels={"Title": name})
#    # Pass the item to the Kodi player.
#    xbmcplugin.setResolvedUrl(_handle, True, listitem=play_item)
#    # directly play the item.
#    xbmc.Player().play(play_url, play_item)


#def search():
#    keyboard = xbmc.Keyboard('', '请输入搜索内容')
#    xbmc.sleep(1500)
#    keyboard.doModal()
#    if (keyboard.isConfirmed()):
#        keyword = keyboard.getText()
#        p_url = "/search?q="
#        url = p_url + \
#            urllib.quote_plus(keyword.decode('utf-8').encode('gb2312'))
#        list_sections(url)
#    else:
#        return

#def router(paramstring):
#    """
#    Router function that calls other functions
#    depending on the provided paramstring
#    :param paramstring:
#    :return:
#    """
#    # Parse a URL-encoded paramstring to the dictionary of
#    # {<parameter>: <value>} elements
#    params = dict(parse_qsl(paramstring))
#    # Check the parameters passed to the plugin
#    if params:
#        if params['action'] == 'index_router':
#            if params['article'] == '/search':
#                search()
#            elif params['article'] == '/maogetvs' or params['article'] == '/alltvs' or params['article'] == '/populartvs':
#                list_sections(params['article'])
#            elif params['article'] == '/categories':
#                list_categories('/alltvs')
#        elif params['action'] == 'list_sections':
#            list_sections(params['section'])
#        elif params['action'] == 'list_series':
#            list_series(
#                params['series'],
#                params["seriesname"],
#                params["fanart_image"])
#        elif params['action'] == 'list_playsource':
#            list_playsource(params['episode'], params["name"])
#        elif params['action'] == 'play_video':
#            play_video(params['episode'], params["name"])

#    else:
#        index()

