namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: uploadFiletoJira
  workflow:
    - uploadFile:
        do:
          Cerner.Integrations.SMAX.subFlows.uploadFile: []
        publish:
          - result
          - message
        navigate:
          - SUCCESS: write_to_file
          - FAILURE: on_failure
    - write_to_file:
        do:
          io.cloudslang.base.filesystem.write_to_file:
            - file_path: "C:\\Temp\\uploadOut.html"
            - text: '${message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      uploadFile:
        x: 218
        'y': 118
      write_to_file:
        x: 319
        'y': 287
        navigate:
          c68c50ff-9076-b380-8c25-1c8a46ee3ed4:
            targetId: 99e43a0f-e9ee-c8db-c2d2-4440acc09966
            port: SUCCESS
    results:
      SUCCESS:
        99e43a0f-e9ee-c8db-c2d2-4440acc09966:
          x: 374
          'y': 90
