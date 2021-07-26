namespace: Cerner.Integrations.CernerStatusDashboard
flow:
  name: Extract_CSDEvents_X_Load_KM
  workflow:
    - Get_CSD_Events_Upload_to_KM:
        do:
          Cerner.Integrations.CernerStatusDashboard.Get_CSD_Events_Upload_to_KM: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_CSD_Events_Upload_to_KM:
        x: 243
        'y': 104
        navigate:
          5d5cc958-86c9-ceb7-58de-318424a096ff:
            targetId: 8d73c523-806f-58aa-423a-8864b7fd60dc
            port: SUCCESS
    results:
      SUCCESS:
        8d73c523-806f-58aa-423a-8864b7fd60dc:
          x: 508
          'y': 91
