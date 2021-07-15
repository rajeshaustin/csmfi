namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: getRequestAttachmentContent
  inputs:
    - attachmentId
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
          - SUCCESS: http_client_get
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('MarketPlace.smaxURL')+'rest/'+get_sp('MarketPlace.tenantID')+'/ces/attachment/600e0b90-4ad4-4416-af7c-18386746b017'}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
            - headers: "${'Cookie: SMAX_AUTH_TOKEN='+sso_token+';TENANTID=336419949'}"
            - content_type: image/png
        publish:
          - attachmentContent: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_sso_token:
        x: 77
        'y': 144
      http_client_get:
        x: 297
        'y': 155
        navigate:
          a5a2f77d-0e68-bc66-7c18-6c62e8c11d5f:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 632
          'y': 274
