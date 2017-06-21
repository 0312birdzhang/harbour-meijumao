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
BLOG_URL = "http://yinwang.org"

def query(url):
    try:
        opener=urllib.request.build_opener()
        data = opener.open(url).read()
        return data
    except urllib.error.HTTPError as e:
        print(str(e))

    


def bloglist():
    html = query(BLOG_URL)
    soup = BeautifulSoup(html,"html.parser")
    lis = soup.find_all(name='li',attrs={
                                               "class":"list-group-item title"
                                               })
    blogs = []
    for i in lis:
        blogs.append({"href":i.a["href"],
                                 "article":(" ".join(i.a.contents)).encode("utf-8")
                                 })
    return blogs

def blogdetail(url):
    html = query(BLOG_URL+url)
    soup = BeautifulSoup(html,"html.parser")
    for i in soup.find_all("div",attrs={"style":"padding: 2% 8% 5% 8%; border: 1px solid LightGrey;"}):
        return i.get_text().encode("utf-8")
