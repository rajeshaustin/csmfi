namespace: Cerner.Integrations.SMAX
flow:
  name: getRequestAttachUploadJira
  inputs:
    - smaxRequestId
    - jiraIssueId
  workflow:
    - get_sso_token:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.get_sso_token:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
        publish:
          - sso_token
          - status_code
          - exception
        navigate:
          - FAILURE: on_failure
          - SUCCESS: query_entities
    - query_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.query_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - entity_type: Request
            - query: "${\"Id='\"+smaxRequestId+\"'\"}"
            - fields: 'DisplayLabel,RequestAttachments'
        publish:
          - entityJsonArray: "${cs_replace(cs_replace(cs_replace(cs_json_query(entity_json,'$..properties.RequestAttachments'),'[\"','',1),'\"]','',1),'\\\\','')}"
          - return_result
          - error_json
          - jiraRequestResultCount: '${result_count}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: jsonArrayToStringList
          - NO_RESULTS: SUCCESS
    - jsonArrayToStringList:
        do:
          Cerner.Integrations.SMAX.subFlows.jsonArrayToStringList:
            - entityArray: '${entityJsonArray}'
        publish:
          - ids
          - result
          - message
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - list_iterator:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${ids}'
            - separator: ♪
        publish:
          - id: '${result_string}'
        navigate:
          - HAS_MORE: download_Attach_Upload_Jira
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - download_Attach_Upload_Jira:
        do:
          Cerner.Integrations.SMAX.subFlows.download_Attach_Upload_Jira:
            - idFileName: '${id}'
            - jiraIssueId: '${jiraIssueId}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator
  outputs:
    - entityJsonArray: '${entityJsonArray}'
    - jiraReqResultCount: '${jiraRequestResultCount}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_sso_token:
        x: 44
        'y': 128
      query_entities:
        x: 37
        'y': 459
        navigate:
          bda183ed-3b69-fbc2-5674-6ccd90d600e5:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: NO_RESULTS
      jsonArrayToStringList:
        x: 188
        'y': 308
      list_iterator:
        x: 162
        'y': 107
        navigate:
          a6f052d2-7e5d-0f00-8429-0afb8c4de874:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: NO_MORE
      download_Attach_Upload_Jira:
        x: 498
        'y': 109
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 619
          'y': 450
