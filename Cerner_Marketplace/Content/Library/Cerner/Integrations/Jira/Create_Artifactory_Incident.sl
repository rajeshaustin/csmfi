namespace: Cerner.Integrations.Jira
flow:
  name: Create_Artifactory_Incident
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
          - FAILURE: on_failure
    - get_priorityId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
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
          - FAILURE: on_failure
    - get_value:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
        navigate:
          - SUCCESS: get_value_2
          - FAILURE: on_failure
    - extractJiraUser_1:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraUser:
            - inpString: '${watcher2}'
        publish:
          - watcher2: '${outString}'
        navigate:
          - SUCCESS: extractJiraUser_2
          - FAILURE: on_failure
    - extractJiraUser_2:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraUser:
            - inpString: '${watcher3}'
        publish:
          - watcher3: '${outString}'
        navigate:
          - SUCCESS: get_priorityId
          - FAILURE: on_failure
    - get_value_2:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraIssueId: '${return_result}'
        navigate:
          - SUCCESS: updateSMAXRequest
          - FAILURE: on_failure
    - updateSMAXRequest:
        do:
          Cerner.Integrations.Jira.subFlows.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        publish: []
        navigate:
          - FAILURE: on_failure
          - SUCCESS: getRequestAttachUploadJira
    - getRequestAttachUploadJira:
        do:
          Cerner.Integrations.SMAX.getRequestAttachUploadJira:
            - smaxRequestId: '${smaxRequestID}'
            - jiraIssueId: '${jiraIssueId}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - incidentCreationCode: '${incidentHttpStatusCode}'
    - incidentCreationResultJSON: '${jiraIncidentCreationResult}'
    - jiraIssueURL: '${jiraIssueURL}'
    - jiraIssueId: '${jiraIssueId}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_priorityId:
        x: 915
        'y': 121
      get_value:
        x: 921
        'y': 456
      extractJiraUser_1:
        x: 400
        'y': 125
      extractJiraUser_2:
        x: 673
        'y': 121
      getRequestAttachUploadJira:
        x: 325
        'y': 266
        navigate:
          b3d23785-4153-4f3e-4dcf-afc9119ed9f9:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      updateSMAXRequest:
        x: 401
        'y': 447
      extractJiraUser:
        x: 133
        'y': 128
      get_value_2:
        x: 618
        'y': 458
      http_client_post:
        x: 927
        'y': 285
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 181
          'y': 448
