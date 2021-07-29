namespace: Cerner.Integrations.Jira
flow:
  name: Create_JiraRequest_Artifactory
  inputs:
    - jiraToolRequestFieldId: customfield_47005
    - swLinkFieldId: customfield_47220
    - criticalJustFieldId: customfield_47251
    - watcherFieldId: customfield_22411
    - artfactReqTypeFieldId: customfield_47218
    - swExistInNexusFieldId: customfield_47219
    - toolInstanceFieldId: customfield_47215
    - projectId: '40703'
    - issueTypeId: '18'
    - jiraToolRequest: '70879'
    - reporter
    - priority
    - criticalityJustification:
        default: ' '
        required: false
    - artifactoryRequestType
    - summary
    - description
    - swLink:
        default: ' '
        required: false
    - watchers:
        required: false
    - smaxRequestID
    - swExistInNexus:
        default: ' '
        required: false
    - deleteFileFolderLink:
        required: false
    - restoreArtifactName:
        required: false
    - restoreRepositoryLink:
        required: false
    - deleteRepoArtifactName:
        required: false
    - deleteRepoLink:
        required: false
    - deleteRepoExplaination:
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
  workflow:
    - formatDescriptionForArtReqType:
        do:
          Cerner.Integrations.Jira.subFlows.formatDescriptionForArtReqType:
            - artifactoryRequestTypeIn: '${artifactoryRequestType}'
            - deleteFileFolderLink: '${deleteFileFolderLink}'
            - deleteRepoArtifactName: '${deleteRepoArtifactName}'
            - deleteRepoLink: '${deleteRepoLink}'
            - deleteRepoExplaination: '${deleteRepoExplaination}'
            - restoreArtifactName: '${restoreArtifactName}'
            - restoreRepoLink: '${restoreRepositoryLink}'
            - descriptionIn: '${description}'
        publish:
          - result
          - message
          - artifactoryRequestType: '${artifactoryRequestTypeOut}'
          - description: '${descriptionOut}'
        navigate:
          - SUCCESS: get_artifactoryRequestType
          - FAILURE: on_failure
    - get_artifactoryRequestType:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.artifactoryRequestType')}"
            - json_path: '${artifactoryRequestType}'
        publish:
          - jiraArtifactReqType: '${return_result}'
        navigate:
          - SUCCESS: get_SWExistsInNexus
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
            - body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"'+criticalJustFieldId+'\": \"'+criticalityJustification+'\",\"description\": \"'+description+'\", \"'+jiraToolRequestFieldId+'\":{ \"id\": \"'+jiraToolRequest+'\" },  \"'+toolInstanceFieldId+'\": ['+artifactoryInstanceJSON+'],\"'+swLinkFieldId+'\": \"'+swLink+'\", \"'+artfactReqTypeFieldId+'\": { \"id\": \"'+jiraArtifactReqType+'\"}, \"'+swExistInNexusFieldId+'\": { \"id\": \"'+swExistInNexus+'\"}, \"'+watcherFieldId+'\": ['+watchersJSON+']  } }'}"
            - content_type: application/json
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - message: '${error_message}'
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
    - get_SWExistsInNexus:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.artifactorySWExistsInRepo')}"
            - json_path: '${cs_replace(swExistInNexus," ","false",1)}'
        publish:
          - swExistInNexus: '${return_result}'
        navigate:
          - SUCCESS: createArtifactoryIdJSON
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
        x: 725
        'y': 120
      get_jira_url:
        x: 650
        'y': 320
      get_priorityId:
        x: 945
        'y': 115
      createArtifactoryIdJSON:
        x: 471
        'y': 121
      get_jira_issueid:
        x: 386
        'y': 318
      getRequestAttachUploadJira:
        x: 388
        'y': 478
        navigate:
          691dbb90-3355-0e00-1562-467a019f0d14:
            targetId: 553ef829-1fc1-c109-9bb2-9238e57b896d
            port: SUCCESS
      get_artifactoryRequestType:
        x: 268
        'y': 121
      get_SWExistsInNexus:
        x: 387
        'y': 1
      updateSMAXRequest:
        x: 101
        'y': 323
      formatDescriptionForArtReqType:
        x: 86
        'y': 121
      http_client_post:
        x: 948
        'y': 319
    results:
      SUCCESS:
        553ef829-1fc1-c109-9bb2-9238e57b896d:
          x: 833
          'y': 468
