namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: getAttachmentsForRequest
  inputs:
    - smaxRequestId
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
    - get_attachment:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('MarketPlace.smaxURL')+\"rest/\"+get_sp('MarketPlace.tenantID')+\"/rest/\"+smaxRequestId+\"ems/Request?layout=id,DisplayLabel,RequestAttachments&type=Request&system=OO\"}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
            - headers: "${'Cookie: SMAX_AUTH_TOKEN='+sso_token+';TENANTID='+get_sp('MarketPlace.tenantID')}"
            - content_type: application/json
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
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
          - entityJsonArray: '${entity_json}'
          - return_result
          - error_json
          - jiraRequestResultCount: '${result_count}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_attachment
          - NO_RESULTS: SUCCESS
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
        x: 77
        'y': 142
      get_attachment:
        x: 280
        'y': 141
        navigate:
          04266b1e-0d74-7e92-4e48-e4d6b474fc05:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
      query_entities:
        x: 233
        'y': 343
        navigate:
          bda183ed-3b69-fbc2-5674-6ccd90d600e5:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: NO_RESULTS
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 632
          'y': 274
