namespace: Cerner.Integrations.SMAX
flow:
  name: Get_Open_Issues_Status_Update
  workflow:
    - Pull_Open_Issues_Status_Jira:
        do:
          Cerner.Integrations.SMAX.Pull_Open_Issues_Status_Jira: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - result
    - message
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Pull_Open_Issues_Status_Jira:
        x: 299
        'y': 184
        navigate:
          4ee0043a-f72d-3af7-04a7-f310edf94749:
            targetId: 43bd3677-7de4-49d3-0bb4-48a8f267615f
            port: SUCCESS
    results:
      SUCCESS:
        43bd3677-7de4-49d3-0bb4-48a8f267615f:
          x: 567.111083984375
          'y': 163.55905151367188
