namespace: Cerner.Integrations.CernerStatusDashboard
flow:
  name: Extract_CSDIncident_X_Load_KM
  workflow:
    - Get_CSD_Incidents_Upload_to_KM:
        do:
          Cerner.Integrations.CernerStatusDashboard.Get_CSD_Incidents_Upload_to_KM: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - result
    - message
    - jresult
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_CSD_Incidents_Upload_to_KM:
        x: 233
        'y': 105.46665954589844
        navigate:
          83f08184-f9de-4d60-cfaf-9f3d7f816fd5:
            targetId: 8d73c523-806f-58aa-423a-8864b7fd60dc
            port: SUCCESS
    results:
      SUCCESS:
        8d73c523-806f-58aa-423a-8864b7fd60dc:
          x: 508
          'y': 91
