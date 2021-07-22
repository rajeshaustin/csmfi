namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testcommand
  workflow:
    - run_command:
        do:
          io.cloudslang.base.cmd.run_command:
            - command: echo $LANG
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      run_command:
        x: 162
        'y': 101
        navigate:
          7f2c2c36-9667-6f29-b3a9-51acd86faf44:
            targetId: 509845ee-ed0a-d37a-88b8-7eba4bdba142
            port: SUCCESS
    results:
      SUCCESS:
        509845ee-ed0a-d37a-88b8-7eba4bdba142:
          x: 301
          'y': 120
