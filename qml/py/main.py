#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 2017年6月23日

@author: debo.zhang
'''
import sys,os
import urllib.request
import urllib.parse
import json
import re
import pyotherside
from basedir import *
from bs4 import BeautifulSoup
import logging
import string

import hashlib
import os,sys

__AUTHOR__ = "BirdZhang"
_meijumao = "http://www.meijumao.net"
__appname__ = "harbour-meijumao"
cachePath=os.path.join(XDG_CACHE_HOME, __appname__, __appname__,"img","")

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
__index__ = [
    ("/search", u"搜索"),
    ("/categories", u"分类"),
    ("/maogetvs", u"猫哥推荐"),
    ("/alltvs", u"所有美剧"),
    ("/populartvs", u"热门美剧"),
    ("/sitemaptvs",u"美剧索引")
]


if not os.path.exists(cachePath):
    os.makedirs(cachePath)

def get(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063',
        'Host': 'www.meijumao.net'
        }
    pyotherside.send('loadStarted')
    req = urllib.request.Request(url,headers=headers)
    try:
        response = urllib.request.urlopen(req,timeout=30)
        allhtml = response.read()
        pyotherside.send('loadFinished')
        #logging.debug(allhtml)
        return allhtml
    except Exception as e:
        logging.debug(str(e))
        logging.debug(url)
        pyotherside.send('loadFailed',str(e))
        return None

def post(url, data):
    data = data.encode('utf-8')
    request = urllib.request.Request(url)
    request.add_header('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
    request.add_header('User-Agent', 'curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.19.1 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2')
    f = urllib.request.urlopen(request, data)
    return f.read().decode('utf-8')

def index():
    return __index__

# get categories
def list_categories(article):
    # html = get(_meijumao + article)
    # if not html:
    #     return []
    # soup = BeautifulSoup(html, "html.parser")
    # listing = []
    # for urls in soup.find_all("a", attrs={"data-remote": "true"}):
    #     listing.append({
    #        "action" : "list_sections",
    #        "section": urls.get("href").replace(_meijumao, ""),
    #        "label" : urls.div.get_text()

    # })
    listing = [
        {'section': '/alltvs', 'action': 'list_sections', 'label': u'所有'}, 
        {'section': '/sections/1', 'action': 'list_sections', 'label': u'喜剧'}, 
        {'section': '/sections/12', 'action': 'list_sections', 'label': u'爱情'}, 
        {'section': '/sections/2', 'action': 'list_sections', 'label': u'动作'}, 
        {'section': '/sections/3', 'action': 'list_sections', 'label': u'科幻'}, 
        {'section': '/sections/4', 'action': 'list_sections', 'label': u'奇幻'}, 
        {'section': '/sections/5','action': 'list_sections', 'label': u'恐怖'}, 
        {'section': '/sections/13', 'action': 'list_sections', 'label': u'惊悚'}, 
        {'section': '/sections/6', 'action': 'list_sections', 'label': u'剧情'}, 
        {'section': '/sections/7', 'action': 'list_sections', 'label': u'犯罪'}, 
        {'section': '/sections/8', 'action': 'list_sections', 'label': u'冒险'}, 
        {'section': '/sections/9', 'action': 'list_sections', 'label': u'悬疑'}, 
        {'section': '/sections/11', 'action': 'list_sections', 'label': u'纪录'}
        ]
    return listing



# get sections
def list_sections(section):
    if section == "#":
        return
    html = get(_meijumao + section)
    if not html:
        return None
    soup = BeautifulSoup(html, "html.parser")
    listing = []
    sections_map = {}
    for section in soup.find_all("article"):
        listing.append({
                    "label":section.div.a.img.get("alt"),
                    "thumbnail":section.div.a.img.get("src"),
                    "action":"list_series",
                    "series":section.div.a.get("href")
            })
    sections_map["datas"] = listing
    # pagination
    will_page = soup.find("ul", attrs={"id": "will_page"}).find_all("li")
    if len(will_page) > 0:
        if will_page[-1].find("a").get("href") != "#":
            sections_map["next_page"] = True
            sections_map["next_section"] = will_page[-1].find("a").get("href")
        else:
            sections_map["next_page"] = False

        if will_page[0].find("a").get("href") != "#":
            sections_map["pre_page"] = True
            sections_map["pre_section"] = will_page[0].find("a").get("href")
        else:
            sections_map["pre_page"] = False
    else:
        sections_map["next_page"] = False
        sections_map["pre_page"] = False

    return json.dumps(sections_map)


def list_series(series):
    html = get(_meijumao + series)
    if not html:
        return None
    soup_series = BeautifulSoup(html, "html.parser")
    soup_series.find('div',class_='fancy-title title-bottom-border').decompose()
    series_data = {}
    fancy = soup_series.find_all("div", attrs={"class":"col_two_third portfolio-single-content col_last nobottommargin"})

    series_data["fancy"] =  "".join([i.prettify() for i in fancy])
    listing = []
    for serie in soup_series.find_all(
            "div", attrs={
            "class": "col-lg-1 col-md-2 col-sm-4 col-xs-4"}):
        if not serie.a:
            continue

#        if not serie.a.get("href").startswith("/"):
#            continue
        listing.append({
            "action":"play_video",
            "label":serie.a.get_text().replace(" ", "").replace("\n", ""),
            "episode":serie.a.get("href")
        })
    series_data["datas"] = listing
    return json.dumps(series_data)



def list_playsource(episode):
    html = get(_meijumao + episode)
    soup_source = BeautifulSoup(html, "html.parser")
    playsources = {}
    listing = []
    for source in soup_source.find_all(
            "a", attrs={
            "class": "button button-small button-rounded"}):
        listing.append({"href":source.get("href").replace(_meijumao,""),
                        "source":source.get_text()})
    playsources["datas"] = listing
    return json.dumps(playsources)


def play_video(episode):
    """
    Play a video by the provided path.
    :param path: str
    :return: None
    """
    if episode.startswith("http"):
        return json.dumps({
            "type":"origin",
            "url":episode
        })
    #episode = episode.replace("show_episode?", "play_episode?")
    html = get(_meijumao + episode)
    if not html:
        return None
    soup_js = BeautifulSoup(html, "html.parser")
    title = ""
    if soup_js.find_all("h1"):
        title = soup_js.find_all("h1")[0].get_text()
    if soup_js.find_all("li", attrs={"class": "active"}):
        title += " - " + soup_js.find_all("li",
                                          attrs={"class": "active"})[0].get_text()
    play_url = ""
    for script in soup_js.find_all('script'):
        matched = re.search('http.*m3u8.*\"', script.get_text())
        if matched:
            return json.dumps({
                "type":"m3u",
                "url":matched.group().replace(
                "\"",
                "").replace(
                "&amp;",
                "&").replace(
                "->application/x-mpegURL",
                "")
                })
    if len(play_url) == 0:
        for iframe in soup_js.find_all("iframe"):
            iframe_src = iframe.attrs['src']
            bdurl = urllib.parse.quote(iframe_src,safe=string.printable)
            return json.dumps({
                    "type":"m3u",
                    "url":getBDyun(bdurl)
                })

    else:
        return json.dumps({
            "type":"origin",
            "url":_meijumao + episode
        })

def getBDyun(bdurl):
    html = get(bdurl)
    soup = BeautifulSoup(html, "html.parser")
    script = soup.find_all("script")[-1].string
    url=""
    for i in script.split("\n"):
        if "url" in i:
            url = i.split(":")[1].strip(" ").replace("'","").replace(",","").replace("\r","")
            break
    data = "url="+url+"&up=0"
    bdjson = json.loads(post("https://meijumao.cn/yunparse/api.php", data))
    if bdjson.get("msg") == "ok":
        return bdjson.get("url")
    else:
        return None

def search(keyword):
    '''
    Search
    :param keyword:
    '''
    p_url = "/search?q="
    url = p_url + keyword.decode('utf-8')
    return list_sections(url)

def sumMd5(s):
    m = hashlib.md5()
    if isinstance(s,str):
        s = s.encode("utf-8")
    m.update(s)
    return m.hexdigest()


def downloadImg(cachedFile,downurl):
    try:
        urllib.request.urlretrieve(downurl,cachedFile)
        return True
    except urllib.error.HTTPError:
        pass
    except urllib.error.ContentTooShortError:
        pass
    return False


def cacheImg(url):
    cachedFile = cachePath+sumMd5(url)
    if os.path.exists(cachedFile):
        return cachedFile
    else:
        if downloadImg(cachedFile,url):
            return cachedFile
        else:
            return url



if __name__ == "__main__":
    print(list_sections("/maogetvs")) #list_series
#     print(list_series("/tvs/110"))
    # print(play_video("/tvs/110/show_episode?episode=214"))
    
