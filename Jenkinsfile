pipeline {
    triggers {
        issueCommentTrigger('.*@zenkins release minor.*')
    }
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Hello!"
                    for (commitFile in pullRequest.files) {
                        echo "SHA: ${commitFile.sha} File Name: ${commitFile.filename} Status: ${commitFile.status}"
                    }
                }
            }
        }
    }
}
