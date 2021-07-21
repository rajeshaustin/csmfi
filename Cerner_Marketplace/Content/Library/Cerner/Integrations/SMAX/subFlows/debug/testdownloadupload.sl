namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testdownloadupload
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
        x: 313
        'y': 153.421875
        navigate:
          28dd000d-7b62-df0f-3e42-1152c28e12b7:
            targetId: 46fd1307-3181-64e5-2a39-917c353ba163
            port: SUCCESS
    results:
      SUCCESS:
        46fd1307-3181-64e5-2a39-917c353ba163:
          x: 523
          'y': 219
