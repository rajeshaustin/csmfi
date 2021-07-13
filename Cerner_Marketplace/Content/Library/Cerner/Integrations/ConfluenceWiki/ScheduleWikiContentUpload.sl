namespace: Cerner.Integrations.ConfluenceWiki
flow:
  name: ScheduleWikiContentUpload
  workflow:
    - ExtractWikiContentXLoadSMAX:
        do:
          Cerner.Integrations.ConfluenceWiki.ExtractWikiContentXLoadSMAX: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      ExtractWikiContentXLoadSMAX:
        x: 230
        'y': 123
        navigate:
          76bddd2c-77f0-3079-9c2a-4026fac10b64:
            targetId: 2f6bae06-d0a7-42e2-4ea6-f07af3c67b9f
            port: SUCCESS
    results:
      SUCCESS:
        2f6bae06-d0a7-42e2-4ea6-f07af3c67b9f:
          x: 489
          'y': 32
