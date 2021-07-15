namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: getBinaryFile
  workflow:
    - downloadWriteFile:
        do:
          Cerner.Integrations.SMAX.subFlows.downloadWriteFile: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      downloadWriteFile:
        x: 242
        'y': 129
        navigate:
          eabf62da-90cd-0018-2d6b-ce320ef40f55:
            targetId: bf2ae34b-c71a-17b6-cf3f-84dc1bf44ff0
            port: SUCCESS
    results:
      SUCCESS:
        bf2ae34b-c71a-17b6-cf3f-84dc1bf44ff0:
          x: 503
          'y': 114
