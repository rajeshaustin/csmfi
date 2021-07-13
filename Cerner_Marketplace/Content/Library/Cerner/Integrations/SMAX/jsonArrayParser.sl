namespace: Cerner.Integrations.SMAX
operation:
  name: jsonArrayParser
  inputs:
    - entityArray
  python_action:
    use_jython: false
    script: "# do not remove the execute function \ndef execute(entityArray):\n    message = \"\"\n    result = \"\"\n    ids = \"\"\n    \n    try:\n        import requests\n        import json\n        \n        #basicAuthCredentials = (user, password) \n\n        #response = requests.get(baseurl + '/rest/api/search/?expand=metadata.labels&cql=label='+tag, auth=basicAuthCredentials)\n        #jr = json.loads(response.content)\n        \n        message = jr\n        results = jr[\"results\"]\n        message = results\n        pages = \"\"\n        try:\n            for content in results:\n                if content[\"content\"][\"type\"] == \"page\":\n                    pages += content[\"content\"][\"id\"] + \"♪\"\n        except Exception as e:\n            ids = \"\"\n        ids = pages\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message, \"ids\": ids }"
  outputs:
    - result
    - message
    - ids
  results:
    - SUCCESS
