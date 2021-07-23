namespace: Cerner.Integrations.Jira
flow:
  name: Create_JiraIncident_Artifactory_List
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
    - jiraToolInstanceL1
    - jiraToolInstanceL2:
        required: false
    - jiraToolInstanceL3:
        required: false
    - jiraToolInstanceL4:
        required: false
    - jiraToolInstanceL5:
        required: false
    - watchers:
        required: false
    - smaxRequestID
  workflow:
    - createArtifactoryIdJSON:
        do:
          Cerner.Integrations.Jira.subFlows.createArtifactoryIdJSON:
            - instanceId1: '${jiraToolInstanceL1}'
            - instanceId2: '${jiraToolInstanceL2}'
            - instanceId3: '${jiraToolInstanceL3}'
            - instanceId4: '${jiraToolInstanceL4}'
            - instanceId5: '${jiraToolInstanceL5}'
        publish:
          - result
          - artifactoryInstanceJSON: '${message}'
        navigate:
          - SUCCESS: extractWathersList
          - FAILURE: on_failure
    - extractWathersList:
        do:
          Cerner.Integrations.Jira.subFlows.extractWathersList:
            - watchers: '${watchers}'
        publish:
          - result
          - watchersJSON: '${message}'
        navigate:
          - SUCCESS: get_priorityId
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
            - body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\": \"'+description+'\", \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+repoURLFieldId+'\": \"'+repoURL+'\", \"'+toolInstanceFieldId+'\": ['+artifactoryInstanceJSON+'], \"'+watcherFieldId+'\": ['+watchersJSON+']  } }'}"
            - content_type: application/json
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - jiraInstanceIdJSON: '${error_message}'
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
        navigate:
          - SUCCESS: get_jira_url
          - FAILURE: on_failure
    - get_jira_url:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
        navigate:
          - SUCCESS: get_jira_issueid
          - FAILURE: on_failure
    - get_jira_issueid:
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
      createArtifactoryIdJSON:
        x: 206
        'y': 114
      extractWathersList:
        x: 469
        'y': 115
      get_priorityId:
        x: 713
        'y': 113
      http_client_post:
        x: 920
        'y': 110
      get_jira_url:
        x: 921
        'y': 456
      get_jira_issueid:
        x: 723
        'y': 454
      updateSMAXRequest:
        x: 531
        'y': 453
      getRequestAttachUploadJira:
        x: 283
        'y': 454
        navigate:
          fe22cd88-2ee0-30e8-d506-a369c6cb8e22:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 598
          'y': 286
