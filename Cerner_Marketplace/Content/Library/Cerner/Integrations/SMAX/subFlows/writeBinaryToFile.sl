namespace: Cerner.Integrations.SMAX.subFlows
operation:
  name: writeBinaryToFile
  inputs:
    - url: 'https://factory-dev.cerner.com/rest/336419949/ces/attachment/600e0b90-4ad4-4416-af7c-18386746b017'
  python_action:
    use_jython: false
    script: "import sys, os\nimport subprocess\n\n# do not remove the execute function \ndef install(param): \n    message = \"\"\n    result = \"\"\n    try:\n        \n        pathname = os.path.dirname(sys.argv[0])\n        message = os.path.abspath(pathname)\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message }\n    # code goes here\n# you can add additional helper methods below.\n\ninstall(\"requests\")\n\nimport requests\n# do not remove the execute function\n\ndef execute(url):\n    local_filename = \"/tmp/Cerner-Logo-square.png\"\n    # NOTE the stream=True parameter below\n    with requests.get(url, stream=True) as r:\n        r.raise_for_status()\n        with open(local_filename, 'wb') as f:\n            for chunk in r.iter_content(chunk_size=8192): \n                # If you have chunk encoded response uncomment if\n                # and set chunk_size parameter to None.\n                #if chunk: \n                f.write(chunk)\n    results=\"True\"\n    message=\"Success\"\n            \n    return {\"results\": results, \"message\": message }"
  outputs:
    - results
    - message
  results:
    - SUCCESS: '${results=="True"}'
    - FAILURE
