namespace: Cerner.Integrations.SMAX.subFlows
operation:
  name: uploadFile
  inputs:
    - url: "${get_sp('MarketPlace.jiraIssueURL')}"
    - user: "${get_sp('MarketPlace.jiraUser')}"
    - password: "${get_sp('MarketPlace.jiraPassword')}"
    - filepath: "C:\\Temp\\test.log"
  python_action:
    use_jython: false
    script: "import sys, os\nimport subprocess\n\n# do not remove the execute function \ndef install(param): \n    message = \"\"\n    result = \"\"\n    try:\n        \n        pathname = os.path.dirname(sys.argv[0])\n        message = os.path.abspath(pathname)\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message }\n    # code goes here\n# you can add additional helper methods below.\n\ninstall(\"jira-python\")\n\n# do not remove the execute function \ndef execute(url, user, password, filepath): \n    message = \"\"\n    result = \"\"\n    token = \"\"\n    try:\n        import requests\n     \n        basicAuthCredentials = requests.auth.HTTPBasicAuth(user,password)\n        attachment = filepath.split(\"\\\\\")[-1]\n        files = [('file',('test.log',open(filepath,'rb'),'text/plain'))]\n        headers = { 'X-Atlassian-Token': 'no-check'}\n        url = url +\"rest/api/2/issue/DFAPPSUP-140/attachments\"\n        response = requests.post(url, files=files, headers=headers, auth=basicAuthCredentials)\n        message = response.text\n        result = \"True\"\n        \n    except Exception as e:\n        message = e\n        result = \"False\"\n        \n    return {\"result\": result, \"message\": message }\n# you can add additional helper methods below."
  outputs:
    - result
    - message
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
