namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: extractWathersList
  inputs:
    - watchers
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(watchers):\n    followers = ''\n    try:\n        if len(watchers.strip()) > 0:\n            if watchers.find(\",\") == -1:\n                followers = '{\"name\":\"'+watchers[0:watchers.find('@')].strip()+'\"}'\n                \n            else:\n                watchers = watchers[1:-1]\n                print(watchers)\n                watchersList = watchers.split(',')\n                for watcher in watchersList:\n                    followers += '{\"name\":\"'+watcher[0:watcher.find('@')].strip()+'\"},'\n                followers = followers[0:-1]   \n    except Exception as e:\n        message = e\n        result = \"False\"\n        \n    result = \"True\"\n    message = followers\n    \n    return{\"result\": result, \"message\": message }\n    \n    # code goes here\n# you can add additional helper methods below."
  outputs:
    - result
    - message
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
