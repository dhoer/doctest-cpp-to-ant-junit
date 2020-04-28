pipeline {
    agent { dockerfile true }
    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
        timestamps()
    }
    stages {
        stage('Test') {
            steps {
                sh('./test.sh')
            }
        }
    }
    post {
        always {
            xunit(tools: [ Custom(customXSL: 'doctest-cpp-to-ant-junit.xsl', pattern: 'test_input/*.doctest') ])
            sh('./clean.sh')
        }
    }
}
