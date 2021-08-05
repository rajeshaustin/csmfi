namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: formatDescriptionForArtReqType
  inputs:
    - artifactoryRequestTypeIn
    - deleteFileFolderLink:
        required: false
    - deleteRepoArtifactName:
        required: false
    - deleteRepoLink:
        required: false
    - deleteRepoExplaination:
        required: false
    - restoreArtifactName:
        required: false
    - restoreRepoLink:
        required: false
    - descriptionIn:
        required: false
  python_action:
    use_jython: false
    script: "def execute(artifactoryRequestTypeIn, deleteFileFolderLink, deleteRepoArtifactName,deleteRepoLink,deleteRepoExplaination,restoreArtifactName, restoreRepoLink,descriptionIn):\r\n    \r\n    description = \"\"\r\n    artifactoryRequestType=\"\"\r\n    \r\n    #descriptionIn = descriptionIn.replace(\"\\\\n\",\"\")\r\n\r\n    try:\r\n        if artifactoryRequestTypeIn ==  \"DeleteFileFolder_c\":\r\n            description = \"File/Folder needing deleted: \"+deleteFileFolderLink+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestType = \"Other_c\"\r\n        elif artifactoryRequestTypeIn ==  \"DeleteRepository_c\":\r\n            if len(deleteRepoLink.strip()) > 0:\r\n                description = \"Name of the Artifact: \"+deleteRepoArtifactName+\"\\\\n Repository Link: \"+deleteRepoLink+\"\\\\n Explanation: \"+deleteRepoExplaination+\"\\\\n\"+descriptionIn\r\n            else:\r\n                description = \"Name of the Artifact: \"+deleteRepoArtifactName+\"\\\\n Explanation: \"+deleteRepoExplaination+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestTypeIn = \"Other_c\"\r\n        elif artifactoryRequestTypeIn ==  \"RestoreFileFolder_c\":\r\n            if len(restoreRepoLink.strip()) > 0:\r\n                description = \"Name of the Artifact: \"+restoreArtifactName+\"\\\\n Repository Link: \"+restoreRepoLink+\"\\\\n\"+descriptionIn\r\n            else:\r\n                description = \"Name of the Artifact: \"+restoreArtifactName+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestType = \"Other_c\"\r\n        else:\r\n            description = descriptionIn\r\n            artifactoryRequestType = artifactoryRequestTypeIn\r\n\r\n            \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        \r\n    result = \"True\"\r\n    message = \"description created successfully\"\r\n    return {\"result\": result, \"message\": message, \"descriptionOut\": description, \"artifactoryRequestTypeOut\": artifactoryRequestType }"
  outputs:
    - result
    - message
    - artifactoryRequestTypeOut
    - descriptionOut
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
