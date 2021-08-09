namespace: Cerner.Integrations.Jira
flow:
  name: Create_JiraIncident_Support
  inputs:
    - projectId: '40703'
    - issueTypeId: '46'
    - reporter
    - priority
    - criticalityJustification:
        default: ' '
        required: false
    - description
    - watcherFieldId:
        default: customfield_22411
        required: false
    - summary
    - watchers:
        required: false
    - smaxRequestID
    - JiraInstance
    - JiraProject
    - ToolRequest: '70703'
  workflow:
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
          - SUCCESS: get_jiraInstanceId
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
            - body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\": \"'+description+'\", \"customfield_47004\":{ \"id\": \"'+ToolRequest+'\" },\"customfield_47247\": {\"id\":\"'+JiraInstanceId+'\"},\"customfield_47248\": \"'+JiraProject+'\"} }'}"
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
          - jiraPriorityId: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
        navigate:
          - SUCCESS: get_jira_issueid
          - FAILURE: on_failure
    - get_jira_issueid:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraPriorityId: '${return_result}'
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
    - get_jiraInstanceId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.JIRAInstanceIDs')}"
            - json_path: '${JiraInstance}'
        publish:
          - JiraInstanceId: '${return_result}'
        navigate:
          - SUCCESS: http_client_post
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
      extractWathersList:
        x: 499
        'y': 115
      get_priorityId:
        x: 714
        'y': 116
      http_client_post:
        x: 921
        'y': 113
      get_jira_url:
        x: 924
        'y': 457
      get_jira_issueid:
        x: 723
        'y': 454
      updateSMAXRequest:
        x: 531
        'y': 455
      getRequestAttachUploadJira:
        x: 283
        'y': 453
        navigate:
          fe22cd88-2ee0-30e8-d506-a369c6cb8e22:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      get_jiraInstanceId:
        x: 822
        'y': 241
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 568
          'y': 307
