namespace: Cerner.Integrations.ConfluenceWiki
operation:
  name: ExtractWikiContentXLoadSMAX
  inputs:
    - conf_tag: "${get_sp('MarketPlace.confluenceTag')}"
    - conf_baseurl: "${get_sp('MarketPlace.confluenceURL')}"
    - conf_user: "${get_sp('MarketPlace.confluenceUser')}"
    - conf_password: "${get_sp('MarketPlace.confluencePassword')}"
    - smax_auth_baseurl: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_password: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_baseurl: "${get_sp('MarketPlace.smaxURL')}"
    - smax_service: '12904'
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for synchronizing Confluence and Smax\r\n#   Author: Pawel Bak Microfocus (pawel.bak@microsoft.com)\r\n#   Inputs:\r\n#       - conf_tag\r\n#       - conf_baseurl\r\n#       - conf_user\r\n#       - conf_password\r\n#       - smax_auth_baseurl\r\n#       - smax_user\r\n#       - smax_password\r\n#       - smax_tenantId\r\n#       - smax_baseurl\r\n#       - smax_service\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - jresult\r\n###############################################################\r\nfrom hashlib import new\r\nimport sys, os\r\nimport subprocess\r\n\r\n# function do download external modules to python \"on-the-fly\" \r\ndef install(param): \r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        \r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message }\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\ninstall(\"lxml\")\r\n\r\n#main function\r\ndef execute(conf_tag, conf_baseurl, conf_user, conf_password, smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl):\r\n    message = \"\"\r\n    result = \"\"\r\n    jresult = \"\"\r\n    oldIds = \"\"\r\n    try:\r\n        \r\n        \r\n        import requests\r\n        import json\r\n        \r\n        basicAuthCredentials = (conf_user, conf_password)\r\n        confRes = BuildConfig(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl)\r\n        if confRes[\"result\"] == \"True\":\r\n            smax_service = confRes[\"smax_ids_conf\"]\r\n            # get IDs of confluence article with specific label (conf_tag)\r\n            giRes = getIds(conf_tag, conf_baseurl, conf_user, conf_password)\r\n            \r\n            foldRes = FindOldArticlesForSourceSystem(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl)\r\n\r\n            if foldRes[\"result\"] == \"True\":\r\n                oldIds = foldRes[\"smax_ids\"]\r\n\r\n\r\n            #check if getting ids from confluence was successfull\r\n            if giRes[\"result\"] == \"True\":\r\n                result = \"True\"\r\n                \r\n                mtagIds = None\r\n\r\n                if smax_service.index(\",\") > 0:\r\n                    gidft = getIdsForTags(smax_service, conf_baseurl, conf_user, conf_password) \r\n                    if gidft[\"result\"] == \"True\":\r\n                        mtagIds = json.loads(gidft[\"ids\"])\r\n\r\n                ids = giRes[\"ids\"].split(\"♪\")\r\n                tresult = json.loads('{}')\r\n                \r\n                i=0\r\n                #loop over ids\r\n                for idv in ids:\r\n                    #print(\"Processing: \" + idv)\r\n                    if len(idv) > 0:\r\n                        #get content from confluence for given ID\r\n                        content =  getBodyForId(idv, conf_baseurl, conf_user, conf_password, \"True\")\r\n                        jresult += idv + \":\"\r\n                        if content[\"result\"] == \"True\":\r\n                            cbody = content[\"body\"]\r\n                            #convert Confluence HTML to standard HTML\r\n                            bodyres = getHTML(cbody, content[\"link\"])\r\n                            \r\n                            if bodyres[\"result\"] == \"True\":\r\n                                cbody = bodyres[\"outHTML\"]\r\n                            \r\n                            smax_service_id = smax_service\r\n                            if mtagIds != None:\r\n                                ftfiRes = findTagsForId(json.dumps(mtagIds),idv, smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl)\r\n                                if ftfiRes[\"result\"] == \"True\":\r\n                                    smax_service_id = ftfiRes[\"firstSmaxService\"]\r\n                                else:\r\n                                    smax_service_id=\"\"\r\n                            if smax_service_id !=\"\":    \r\n                                #insert of update Articel Into SMAX\r\n                                response = insertUpdateArticle(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl, content[\"title\"], cbody, smax_service_id, \"Content From Confluence\", idv)\r\n                                \r\n                                #check status and update result\r\n                                if response[\"result\"] == \"True\":\r\n                                    oldIds = removeIdFromList(oldIds, response[\"oldid\"])\r\n                                    jresult += \"TRUE;\"\r\n                                else:\r\n                                    jresult += \"FALSE_3;\"\r\n                            else:\r\n                                jresult += \"FALSE_2;\"\r\n                        else:\r\n                            jresult += \"FALSE_1;\"\r\n                    #print(\"Processing DONE\")\r\n                if len(oldIds) > 0:\r\n                                        \r\n                    RemoveOldContent(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl, oldIds, conf_tag, conf_baseurl, conf_user, conf_password)        \r\n            else:\r\n                result = \"False\"\r\n        else:\r\n            result = \"False\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"jresult\": str(jresult) }\r\n\r\n#get IDS for specific label from Confuence\r\ndef getIds(tag, baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    ids = \"\"\r\n    \r\n    if tag == \"*\":  \r\n        return {\"result\": \"True\", \"message\": \"\", \"ids\": \"\" }\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        import time\r\n\r\n        basicAuthCredentials = (user, password)\r\n        doloop = True\r\n        start = 0\r\n        total = 0\r\n        page = 25\r\n        pages = \"\"\r\n\r\n        cookies1 = {}\r\n        while doloop:\r\n            turl = '{0}/rest/api/search/?expand=metadata.labels&cql=label={1}&limit={2}&start={3}'.format(baseurl, tag,page,start)\r\n            \r\n            response = requests.get(turl, requests.get, auth=basicAuthCredentials, cookies=cookies1)\r\n            jr = json.loads(response.content)\r\n\r\n            cookies1 = response.cookies.get_dict('wiki.cerner.com')\r\n            \r\n            message = jr\r\n            results = jr[\"results\"]\r\n            totalSize = jr[\"totalSize\"]\r\n            message = results\r\n            \r\n            try:\r\n                for content in results:\r\n                    if content[\"content\"][\"type\"] == \"page\":\r\n                        pages += content[\"content\"][\"id\"] + \"♪\"\r\n            except Exception as e:\r\n                ids = \"\"\r\n            total = start + page\r\n            start += page\r\n            doloop = totalSize >= total\r\n            #time.sleep(5)\r\n        \r\n        ids = pages\r\n        if len(ids) > 0:\r\n            ids = ids[:-1]\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"ids\": ids }\r\n\r\ndef getIdsForTags(tags_list, baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    ids = \"\"\r\n    \r\n    try:\r\n        import json\r\n        serv_tag = tags_list.split(\",\")\r\n        rids = [0]*len(serv_tag)\r\n        i=0\r\n        for st in serv_tag:\r\n            sti = st.split(\":\")\r\n            if sti[0] != \"*\":\r\n                gidr = getIds(sti[0], baseurl, user, password)\r\n                if gidr[\"result\"] == \"True\":\r\n                    rids[i] = {\"tag\": sti[0], \"smax_id\": sti[1], \"ids\": gidr[\"ids\"]}\r\n                else:\r\n                    rids[i] = {\"tag\": sti[0], \"smax_id\": sti[1], \"ids\": \"\"}\r\n            else:\r\n                rids[i] = {\"tag\": sti[0], \"smax_id\": sti[1], \"ids\": \"\"}\r\n            i+=1\r\n\r\n        ids = json.dumps(rids)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"ids\": ids }\r\n\r\ndef findTagsForId(tag_ids, id, auth_baseurl, user, password, tenantId, smax_baseurl):\r\n    message = \"\"\r\n    result = \"\"\r\n    firstTag = \"\"\r\n    firstSmaxService = \"\"\r\n    try:\r\n        import json\r\n        jtags = json.loads(tag_ids)\r\n        \r\n        \r\n        for tag in jtags:\r\n            if tag[\"tag\"] == \"*\":   \r\n                firstTag = tag[\"tag\"]\r\n                firstSmaxService = tag[\"smax_id\"]\r\n                break\r\n        \r\n        for tag in jtags:\r\n            ids = tag[\"ids\"].split(\"♪\")\r\n            found = False\r\n            for idv in ids:\r\n                if idv == id:\r\n                    found = True\r\n            if found:\r\n                firstTag = tag[\"tag\"]\r\n                firstSmaxService = tag[\"smax_id\"] \r\n                break\r\n        \r\n        if firstSmaxService.isnumeric() != True:\r\n            res = FindServiceByName(auth_baseurl, user, password, tenantId, smax_baseurl, firstSmaxService)\r\n            if res[\"result\"] == \"True\":\r\n                firstSmaxService = res[\"smax_id\"]\r\n            else:\r\n                firstSmaxService = \"\"\r\n                result = \"False\"\r\n\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"firstTag\": firstTag, \"firstSmaxService\": firstSmaxService }\r\n\r\n\r\n#Get content for specific ID in confluence\r\ndef getBodyForId(contentID, baseurl, user, password, replaceRelative):\r\n    message = \"\"\r\n    result = \"\"\r\n    body = \"\"\r\n    title = \"\"\r\n    status = \"\"\r\n    content_type = \"\"\r\n    link = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        \r\n        basicAuthCredentials = (user, password)\r\n \r\n        response = requests.get(baseurl + '/rest/api/content/'+contentID+'?expand=body.view', auth=basicAuthCredentials)\r\n        jr = json.loads(response.content)\r\n        \r\n        message = jr\r\n        status = jr[\"status\"]\r\n        link = jr[\"_links\"][\"base\"] + jr[\"_links\"][\"webui\"] \r\n        content_type = jr[\"type\"]\r\n        \r\n        try:\r\n            title = jr[\"title\"]\r\n        except Exception as e:\r\n            title = \"NO_TITLE\"\r\n        \r\n        try:\r\n            body = jr[\"body\"][\"view\"][\"value\"]\r\n            if replaceRelative == \"True\":\r\n                body = body.replace(\"\\\"/\", \"\\\"\"+baseurl+\"/\")\r\n        except Exception as e:\r\n            body = \"NO_BODY\"\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"body\": body, \"title\": title, \"status\": status, \"content_type\": content_type, \"link\":link }\r\n\r\ndef hasTag(auth_baseurl, user, password, tenantId, smax_baseurl, smax_Id, conf_tag, conf_baseurl, conf_user, conf_password):\r\n    message = \"\"\r\n    result = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        result = \"False\"\r\n        smaxr =  FindArticleForId(auth_baseurl, user, password, tenantId, smax_baseurl, smax_Id)\r\n        if smaxr[\"result\"] == \"True\":\r\n            confTagr = getTagsForId(smaxr[\"conf_id\"], conf_baseurl, conf_user, conf_password)\r\n            if confTagr[\"result\"] == \"True\":\r\n                tags = confTagr[\"tags\"].split(\"♪\")\r\n                for tag in tags:\r\n                    if tag == conf_tag:\r\n                        result = \"True\"\r\n                        break\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n#Get content for specific ID in confluence\r\ndef getTagsForId(contentID, baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    tags = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        \r\n        basicAuthCredentials = (user, password)\r\n \r\n        response = requests.get(baseurl + '/rest/api/content/'+contentID+'/label', auth=basicAuthCredentials)\r\n        jr = json.loads(response.content)\r\n        \r\n        for tag in jr[\"results\"]:\r\n            tags += tag[\"name\"] + \"♪\"\r\n\r\n        if len(tags) > 0:\r\n            tags = tags[:-1]\r\n\r\n        message = jr\r\n        \r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"tags\": tags }\r\n\r\n\r\n\r\n# insert or update Knowladge Article in SMAX\r\ndef insertUpdateArticle(auth_baseurl, user, password, tenantId, smax_baseurl, title, concont, service, description, cid):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    oldid = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        \r\n        basicAuthCredentials = (user, password)\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n\r\n        oldRecord = FindArticleForConfluenceID(auth_baseurl, user, password, tenantId, smax_baseurl, cid)\r\n\r\n        data = generateJson(title, concont, service, description, cid)                 \r\n        \r\n        token = \"\"\r\n        \r\n        if oldRecord[\"result\"] == \"True\":\r\n            oldid = oldRecord[\"smax_id\"]\r\n            if data['entities'][0][\"properties\"][\"ConfluenceArticleHash_c\"] != oldRecord[\"conf_hash\"]:\r\n                data['entities'][0][\"properties\"][\"Id\"] = oldRecord[\"smax_id\"]\r\n                data['operation'] = \"UPDATE\"\r\n                response = requests.post(smax_baseurl+\"/rest/\"+tenantId+\"/ems/bulk\", json=data, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n                message = response.text\r\n                if response.status_code == 200:\r\n                    token = \"Record (ID:\"+data['entities'][0][\"properties\"][\"Id\"]+\") UPDATED\"\r\n                else:\r\n                    token = \"Record (ID:\"+data['entities'][0][\"properties\"][\"Id\"]+\") NOT-UPDATED\"\r\n            else:\r\n                token = \"Record (ID:\"+oldRecord[\"smax_id\"]+\") HASH the same, no update needed\"\r\n        else:\r\n            response = requests.post(smax_baseurl+\"/rest/\"+tenantId+\"/ems/bulk\", json=data, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n            message = response.text\r\n            if response.status_code == 200:\r\n                token = \"Record Created!\"\r\n            else:\r\n                token = \"Issue Creating Record!\"\r\n                \r\n\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_response\": token, \"oldid\":oldid }\r\n\r\n#generate data structure for SMAX\r\ndef generateJson(title, concont, service, description, cid, operation=\"CREATE\"):\r\n    data2 ={}\r\n    data2['entities'] = [1]\r\n    data2['entities'][0] = {}\r\n    data2['entities'][0][\"entity_type\"] = \"Article\"\r\n    data2['entities'][0][\"properties\"] = {}\r\n    data2['entities'][0][\"properties\"][\"Title\"] = title\r\n    data2['entities'][0][\"properties\"][\"Content\"] = concont\r\n    data2['entities'][0][\"properties\"][\"Service\"] = service\r\n    data2['entities'][0][\"properties\"][\"Description\"] = description\r\n    data2['entities'][0][\"properties\"][\"ConfluenceArticleID_c\"] = cid\r\n    data2['entities'][0][\"properties\"][\"ConfluenceArticleHash_c\"] = createHash(concont)[\"hash_object\"]\r\n    data2['entities'][0][\"properties\"][\"Subtype\"] = \"Article\"\r\n    data2['entities'][0][\"properties\"][\"SourceSystem_c\"] = \"CernerWiki\"\r\n    data2['entities'][0][\"properties\"][\"PhaseId\"] = \"External\"\r\n    data2['entities'][0][\"related_properties\"] = {}\r\n    data2['operation'] = operation\r\n    return data2\r\n\r\n#authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    try:\r\n        import requests\r\n        basicAuthCredentials = (user, password)\r\n        data={}\r\n        data['Login'] = user\r\n        data['Password']= password\r\n\r\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\r\n        token = response.text\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_auth\": token }\r\n\r\n#Content hash function\r\ndef createHash(inputString):\r\n    message = \"\"\r\n    result = \"\"\r\n    hash_object = \"\"\r\n    try:\r\n        import hashlib\r\n        # Assumes the default UTF-8\r\n        hash_object = hashlib.md5(inputString.encode()).hexdigest()\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"hash_object\":hash_object}\r\n\r\n#search function for Confluence\r\ndef FindArticleForConfluenceID(auth_baseurl, user, password, tenantId, smax_baseurl, cID):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_id = \"\"\r\n    conf_hash = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        turl = smax_baseurl +\"/rest/\"+tenantId+\"/ems/Article?layout=Id,ConfluenceArticleID_c,ConfluenceArticleHash_c,PhaseId&filter=ConfluenceArticleID_c%3D'\"+cID+\"'\"\r\n        response3 = requests.get(turl, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        \r\n        result = \"False\"\r\n        if response3.status_code == 200:\r\n            jdata = json.loads(response3.text)\r\n            smax_id = jdata['entities'][0][\"properties\"][\"Id\"]\r\n            conf_hash = jdata['entities'][0][\"properties\"][\"ConfluenceArticleHash_c\"]\r\n            result = \"True\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_id\":smax_id, \"conf_hash\":conf_hash}\r\n\r\n\r\n#search function for Confluence\r\ndef FindArticleForId(auth_baseurl, user, password, tenantId, smax_baseurl, Id):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_id = \"\"\r\n    conf_id = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        turl = smax_baseurl +\"/rest/\"+tenantId+\"/ems/Article?layout=Id,ConfluenceArticleID_c,ConfluenceArticleHash_c,PhaseId&filter=Id%3D'\"+Id+\"'\"\r\n        response3 = requests.get(turl, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        \r\n        result = \"False\"\r\n        if response3.status_code == 200:\r\n            jdata = json.loads(response3.text)\r\n            smax_id = jdata['entities'][0][\"properties\"][\"Id\"]\r\n            conf_id = jdata['entities'][0][\"properties\"][\"ConfluenceArticleID_c\"]\r\n            result = \"True\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_id\":smax_id, \"conf_id\":conf_id}\r\n\r\n\r\n#search function for Service\r\ndef FindServiceByName(auth_baseurl, user, password, tenantId, smax_baseurl, ServiceName):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_id = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        turl = smax_baseurl +\"/rest/\"+tenantId+\"/ems/ServiceDefinition?layout=Id,DisplayLabel,Category,MarketPlaceWikiTag_c&filter=DisplayLabel%3D'\"+ServiceName+\"'\"\r\n        response3 = requests.get(turl, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        \r\n        result = \"False\"\r\n        if response3.status_code == 200:\r\n            jdata = json.loads(response3.text)\r\n            smax_id = jdata['entities'][0][\"properties\"][\"Id\"]\r\n            result = \"True\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_id\":smax_id}\r\n\r\n#search function for Service\r\ndef BuildConfig(auth_baseurl, user, password, tenantId, smax_baseurl):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_ids_conf = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        turl = smax_baseurl +\"/rest/\"+tenantId+\"/ems/ServiceDefinition?layout=Id,DisplayLabel,Category,MarketPlaceWikiTag_c&filter=MarketPlaceWikiTag_c%21%3D''\"\r\n        response3 = requests.get(turl, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        \r\n        result = \"False\"\r\n        if response3.status_code == 200:\r\n            jdata = json.loads(response3.text)\r\n            for ent in jdata['entities']:\r\n                try:\r\n                    smax_ids_conf += ent[\"properties\"][\"MarketPlaceWikiTag_c\"]+ \":\" +ent[\"properties\"][\"Id\"]+\",\"\r\n                except:\r\n                    smax_ids_conf += \"\"\r\n            \r\n            result = \"True\"\r\n        \r\n        if len(smax_ids_conf)>0:\r\n            smax_ids_conf = smax_ids_conf[:-1]\r\n        else:\r\n            result = \"False\"\r\n            message = \"Config Not Found\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_ids_conf\":smax_ids_conf}\r\n\r\n#HTML convertion for Confluence HTML content\r\ndef getHTML(inHTML, link):\r\n    message = \"\"\r\n    result = \"\"\r\n    outHTML = \"\"\r\n    \r\n    try:\r\n\r\n        from lxml import html, etree\r\n        #print(\"     Processing: \" + link)\r\n        link_template = \"<div><span>Original page can be found at: </span><a href=\\\"\"+link+\"\\\">\" + link + \"</a><div><br/>\"\r\n        xslt_text = \"<xsl:stylesheet version=\\\"1.0\\\"\\r\\n xmlns:xsl=\\\"http://www.w3.org/1999/XSL/Transform\\\"\\r\\n xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\">\\r\\n <xsl:output omit-xml-declaration=\\\"yes\\\" indent=\\\"yes\\\"/>\\r\\n <xsl:strip-space elements=\\\"*\\\"/>\\r\\n\\r\\n <xsl:template match=\\\"p|div|br|a|h1|h2|h3|li|ul|ol|u|strong|table|td|tr|img|span|@*\\\">\\r\\n     <xsl:copy>\\r\\n       <xsl:apply-templates select=\\\"node()|@*\\\"/>\\r\\n     </xsl:copy>\\r\\n </xsl:template>\\r\\n\\r\\n <xsl:template match=\\\"code\\\"/>\\r\\n</xsl:stylesheet>\"\r\n\r\n        xslt_doc = etree.fromstring(xslt_text)\r\n        inHTML = inHTML.replace(\"\\n\",\"\").replace(\"\\t\",\"\")\r\n        transform = etree.XSLT(xslt_doc)\r\n        ehtml = html.fromstring(inHTML)\r\n        docs = etree.tostring(ehtml)\r\n        result = transform(ehtml)\r\n\r\n        docs = etree.tostring(result)\r\n\r\n        outHTML = link_template + str(bytes.decode(docs).replace(\"\\&quot;\",\"\").replace(\"\\\\n\",\"\").replace(\"&#194;&#160;\", \"&nbsp;\").replace(\"&lt;\", \"<\").replace(\"&gt;\", \">\")) + \" \"\r\n        \r\n        #print(\"     Processing +DONE+\\n\")\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        print(message)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"outHTML\": outHTML }\r\n    #return inHTML\r\n\r\n#search function for Confluence\r\ndef FindOldArticlesForSourceSystem(auth_baseurl, user, password, tenantId, smax_baseurl, SourceSystem=\"CernerWiki\"):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_ids = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        authResp = getAuthCookie(auth_baseurl, user, password)\r\n        if authResp[\"result\"] == \"True\":\r\n            token = authResp[\"smax_auth\"]\r\n        \r\n        authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        turl = smax_baseurl +\"/rest/\"+tenantId+\"/ems/Article?layout=Id,SourceSystem_c,Title,PhaseId&filter=SourceSystem_c%3D'\"+SourceSystem+\"'\"\r\n        response3 = requests.get(turl, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        \r\n        result = \"False\"\r\n        if response3.status_code == 200:\r\n            jdata = json.loads(response3.text)\r\n            \r\n            for entity in jdata['entities']:\r\n            \r\n                smax_ids += entity[\"properties\"][\"Id\"] + \"♪\"\r\n            \r\n            if len(smax_ids) > 0:\r\n                smax_ids = smax_ids[:-1]\r\n            result = \"True\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_ids\":smax_ids }\r\n\r\ndef RemoveOldContent(auth_baseurl, user, password, tenantId, smax_baseurl, ids, conf_tag, conf_baseurl, conf_user, conf_password):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    smax_ids = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        if len(ids) > 0:\r\n            \r\n            basicAuthCredentials = (user, password)\r\n            authResp = getAuthCookie(auth_baseurl, user, password)\r\n            if authResp[\"result\"] == \"True\":\r\n                token = authResp[\"smax_auth\"]\r\n        \r\n            authHeaders = { \"TENANTID\": \"keep-alive\"}\r\n            cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n\r\n            oldIDs = ids.split(\"♪\")\r\n            for oid in ids.split(\"♪\"):\r\n                if hasTag(auth_baseurl, user, password, tenantId, smax_baseurl, id, conf_tag, conf_baseurl, conf_user, conf_password)[\"result\"] == \"True\":\r\n                    oldIDs = removeIdFromList(oldIDs,oid)\r\n\r\n            if len(oldIDs) > 0:\r\n                i=0\r\n                smaxData={}\r\n                smaxData[\"entities\"] = [0]*len(oldIDs)\r\n                smaxData[\"operation\"] = \"DELETE\"\r\n\r\n                for id in oldIDs:\r\n                    smaxData[\"entities\"][i]={}\r\n                    smaxData[\"entities\"][i][\"entity_type\"] = \"Article\"\r\n                    smaxData[\"entities\"][i][\"properties\"] = {}\r\n                    smaxData[\"entities\"][i][\"properties\"][\"Id\"] = id\r\n                    i+=1\r\n\r\n\r\n                response = requests.post(smax_baseurl+\"/rest/\"+tenantId+\"/ems/bulk\", json=smaxData, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n            \r\n                if response.status_code == 200:\r\n                    result = \"True\"\r\n                    message = \"OK\"\r\n                else:\r\n                    result = \"False\"\r\n                    message = response.text\r\n            else:\r\n                message = \"Nothing To Remove\"\r\n                result = \"True\"\r\n        else:\r\n            message = \"Nothing To Remove\"\r\n            result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message }\r\n\r\ndef removeIdFromList(list, id):\r\n    newlist = \"\"\r\n    if len(id) == 0:\r\n        return list\r\n    if len(list) > 0:\r\n        elems = list.split(\"♪\")\r\n        for elem in elems:\r\n            if elem != id:\r\n                newlist += elem + \"♪\"\r\n        if len(newlist) > 0:\r\n            newlist = newlist[:-1]\r\n        return newlist\r\n    else:\r\n        return \"\""
  outputs:
    - jresult
    - result
    - message
  results:
    - SUCCESS: "${result=='True'}"
    - FAILURE
