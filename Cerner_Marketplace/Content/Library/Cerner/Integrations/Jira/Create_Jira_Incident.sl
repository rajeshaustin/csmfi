namespace: Cerner.Integrations.Jira
flow:
  name: Create_Jira_Incident
  inputs:
    - projectId: '40703'
    - issueTypeId: '46'
    - reporter
    - priority
    - criticalityJustification:
        default: ' '
        required: false
    - description
    - jiraToolFieldId: customfield_47004
    - repoURLFieldId: customfield_47216
    - toolInstanceFieldId: customfield_47215
    - watcherFieldId: customfield_22411
    - summary
    - jiraTool: '70856'
    - repoURL:
        default: ' '
        required: false
    - jiraToolInstance
    - watcher1:
        required: false
    - watcher2:
        required: false
    - watcher3:
        required: false
    - smaxRequestID
  workflow:
    - extractJiraUser:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraUser:
            - inpString: '${watcher1}'
        publish:
          - watcher1: '${outString}'
        navigate:
          - SUCCESS: extractJiraUser_1
          - FAILURE: FAILURE
    - get_value_1:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: FAILURE
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue'}"
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\": \"'+description+'\", \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+repoURLFieldId+'\": \"'+repoURL+'\", \"'+toolInstanceFieldId+'\": [{ \"id\": \"'+jiraToolInstance+'\"}], \"'+watcherFieldId+'\": [{\"name\": \"'+watcher1+'\"}, {\"name\": \"'+watcher2+'\"},{\"name\": \"'+watcher3+'\"}]  } }'}"
            - content_type: application/json
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - error_message
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
        navigate:
          - SUCCESS: get_value
          - FAILURE: FAILURE
    - get_value:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
        navigate:
          - SUCCESS: get_value_2
          - FAILURE: FAILURE
    - extractJiraUser_1:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraUser:
            - inpString: '${watcher2}'
        publish:
          - watcher2: '${outString}'
        navigate:
          - SUCCESS: extractJiraUser_2
          - FAILURE: FAILURE
    - extractJiraUser_2:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraUser:
            - inpString: '${watcher3}'
        publish:
          - watcher3: '${outString}'
        navigate:
          - SUCCESS: get_value_1
          - FAILURE: FAILURE
    - get_value_2:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraIssueId: '${return_result}'
        navigate:
          - SUCCESS: updateSMAXRequest
          - FAILURE: FAILURE
    - updateSMAXRequest:
        do:
          Cerner.Integrations.Jira.subFlows.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        publish: []
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS
  outputs:
    - incidentCreationCode: '${incidentHttpStatusCode}'
    - incidentCreationResultJSON: '${jiraIncidentCreationResult}'
    - jiraIssueURL: '${jiraIssueURL}'
    - jiraIssueId: '${jiraIssueId}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      extractJiraUser:
        x: 133
        'y': 128
        navigate:
          bfd3b724-8b69-66c8-e294-ab56b6ff2c4e:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      get_value_1:
        x: 915
        'y': 121
        navigate:
          1d70c42c-a71a-beb2-51e2-61404472bea6:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      http_client_post:
        x: 924
        'y': 285
        navigate:
          372aaa08-9d28-6a0e-828f-d2cea650efe8:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      get_value:
        x: 922
        'y': 456
        navigate:
          935d1786-7a8d-394d-f5e2-73c14cbac295:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      extractJiraUser_1:
        x: 400
        'y': 125
        navigate:
          3ab8735e-a0fb-6f5c-8338-549e72622b49:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      extractJiraUser_2:
        x: 673
        'y': 121
        navigate:
          e5580e40-2b81-e463-fe75-8dc18816a4d1:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      get_value_2:
        x: 616
        'y': 457
        navigate:
          2c68dbbc-7ea2-ad20-d988-81607fc21c51:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
      updateSMAXRequest:
        x: 399
        'y': 445
        navigate:
          c7de86bc-44a6-5185-bc07-0daa29cad3ef:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
          3453741c-7ed4-aa03-afd2-ac3c0113f198:
            targetId: 7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1
            port: FAILURE
    results:
      FAILURE:
        7a2d1ff5-24e7-1cf8-3988-a2a1b914c7e1:
          x: 614
          'y': 302
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 181
          'y': 448
