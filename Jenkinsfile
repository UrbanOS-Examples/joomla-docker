library(
    identifier: 'pipeline-lib@4.6.1',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger()]),
])

def image
def doStageIf = scos.&doStageIf
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)
def doStageUnlessRelease = doStageIf.curry(!scos.changeset.isRelease)
def doStageIfPromoted = doStageIf.curry(scos.changeset.isMaster)

node ('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageUnlessRelease('Build') {
            image = docker.build("scos/joomla:${env.GIT_COMMIT_HASH}")
        }

        doStageUnlessRelease('Tag Dev Image') {
            scos.withDockerRegistry {
                image.push()
                image.push('development')
            }
        }

        doStageIfRelease('Tag Release Image') {
            scos.withDockerRegistry {
                image = scos.pullImageFromDockerRegistry("scos/joomla", env.GIT_COMMIT_HASH)
                image.push()
                image.push(env.BRANCH_NAME)
            }
        }
    }
}