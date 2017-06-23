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
from bs4 import BeautifulSoup
import logging

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



def get(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063',
        'Host': 'www.meijumao.net'
        }
    req = urllib.request.Request(url,headers=headers)
    try:
        response = urllib.request.urlopen(req,timeout=30)
        allhtml = response.read()
        return allhtml
    except Exception as e:
        print(str(e))
        #logging.debug(traceback.format_exc())
        return ''
    

def index():
    return __index__

# get categories
def list_categories(article):
    html = get(_meijumao + article)
    soup = BeautifulSoup(html, "html.parser")
    listing = []
    for urls in soup.find_all("a", attrs={"data-remote": "true"}):
        listing.append({
           "action" : "list_sections",
           "section": urls.get("href").replace(_meijumao, ""),
           "label" : urls.div.get_text()

    })
    return listing



# get sections
def list_sections(section):
    if section == "#":
        return
    html = get(_meijumao + section)
    soup = BeautifulSoup(html, "html.parser")
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
    return json.dumps(sections_map)


def list_series(series):
    html = get(_meijumao + series)
    soup_series = BeautifulSoup(html, "html5lib")

    listing = []
    for serie in soup_series.find_all(
            "div", attrs={
            "class": "col-lg-1 col-md-2 col-sm-4 col-xs-4"}):
        if not serie.a:
            continue

        if not serie.a.get("href").startswith("/"):
            continue
        listing.append({
                "action":"play_video",
                "label":serie.a.get_text().replace(" ", "").replace("\n", ""),
                "episode":serie.a.get("href")
            })
    return listing
  


def list_playsource(episode):
    html = get(_meijumao + episode)
    soup_source = BeautifulSoup(html, "html5lib")
    listing = []
    for source in soup_source.find_all(
            "a", attrs={
            "class": "button button-small button-rounded"}):
#         if source.get("href").startswith("http"):
#             continue
        listing.append({"href":source.get("href"),
                        "source":source.get_text()})
    return listing


def play_video(episode):
    """
    Play a video by the provided path.
    :param path: str
    :return: None
    """
    episode = episode.replace("show_episode?", "play_episode?")
    html = get(_meijumao + episode)
    if not html:
        return None
    soup_js = BeautifulSoup(html, "html5lib")
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
            return matched.group().replace(
                "\"",
                "").replace(
                "&amp;",
                "&").replace(
                "->application/x-mpegURL",
                "")
    if len(play_url) == 0:
        return None

def search(keyword):
    '''
    Search 
    :param keyword:
    '''
    p_url = "/search?q="
    url = p_url + keyword.decode('utf-8').encode('gb2312')
    return list_sections(url)



if __name__ == "__main__":
#     print(list_sections("/maogetvs")) #list_series
#     print(list_series("/tvs/110"))
    print(play_video("/tvs/110/show_episode?episode=214"))
