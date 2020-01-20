
node {
  stage ('checkout') {
    try {
      sh 'mkdir cookbook'
      dir("${env.WORKSPACE}/cookbook") {
        checkout scm
      }
    } catch (error) {
      echo '"checkout" stage caught an error'
      throw error
    }
  }
  dir("${env.WORKSPACE}/cookbook") {
    stage('linting') {
      try {
        sh 'chef exec cookstyle -D .'
        sh 'chef exec foodcritic .'
      } catch (error) {
        echo '"linting" stage caught an error'
        throw error
      }
    }
    stage('unit testing') {
      try {
        sh 'chef exec rspec -fd'
      } catch (error) {
        echo '"unit testing" stage caught an error'
        throw error
      }
    }
    stage('build') {
      try {
        sh 'kitchen converge'
      } catch (error) {
        echo '"build" stage caught an error'
        throw error
      }
    }
    stage('integration testing') {
      try {
        sh 'chef exec rspec -fd'
      } catch (error) {
        echo '"integration testing" stage caught an error'
        throw error
      }
    }
    if ( env.BRANCH_NAME == 'master' ) {
      stage('push to chef server') {
        try {
          echo "Made it to deployment! But skipping for now!!" 
          // sh """
          //   knife cookbook upload docker-prometheus --freeze
          // """
        } catch (error) {
          echo '"push to chef server" stage caught an error'
          throw error
        }
      }
    } else {
      echo "'${env.BRANCH_NAME}' is not a deployable branch"
    }
  }
  stage('clean up') {
    try {
      sh 'kitchen destroy'
      sh "rm -rf ${env.WORKSPACE}/*"
    } catch (error) {
      echo '"clean up" stage caught an error'
      throw error
    }
  }
}