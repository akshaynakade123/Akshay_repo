node {  
    agent { label 'node1' }

    stage('Build') { 
        echo 'hello everyone' 
    }
    stage('Test') { 
        sh 'touch vaibhav.txt' 
    }
    stage('Deploy') { 
        sh 'mkdir koma'
    }
}