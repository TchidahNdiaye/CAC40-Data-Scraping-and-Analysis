# -*- coding: utf8 -*-

import requests
import pdb
import time
import re
import pickle
import os
import html
import csv

# Extraction des pages de chaque action
for k in ['l.v.m.h.','accor','air-liquide','eads','arcelormittal-reg','atos-origin','axa','bnp-paribas','bouygues','cap-gemini','carrefour','credit-agricole','danone','dassault-system','gdf-suez','essilor-internat','hermes-international','kering','l-oreal','legrand','michelin','france-telecom','pernod-ricard','peugeot','publicis-groupe','renault','safran','saint-gobain','sanofi-aventis','schneider-electr','societe-generale','sodexho-alliance','stmicroelectroni','thales','total','veolia-environ','vinci','vivendi','uniball','worldline-sa']:
    url='https://fr.investing.com/equities/'+k
    request_headers={'User-Agent': "(Mozilla/5.0 (Windows; U; Windows NT 6.0;en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6" }

    i=0
    while i<5:
        j=0
        while j<5:
            try:
                req=requests.get(url,headers=request_headers,timeout=10)
                j=1000
            except:
                time.sleep(1)
                j=j+1

        if j==1000:
            if req.status_code==200:
                content=req.text
                with open('pagescollectees/'+k+'.txt','w',encoding='utf8') as output:
                    output.write(content)

                i=1000
            else:
                i=i+1
                time.sleep(1)

    if i==1000:
        print("code source de la page",k,"est collecté")
    else:
        if j==1000:
            print("probléme au niveau de la collecte de la page ",k)
        else:
            print("problème au niveau du timeout",k)

pdb.set_trace()

