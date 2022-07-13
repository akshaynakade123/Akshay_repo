node {  
    stage('Build') { 
        echo 'hello everyone' 
    }
    stage('Test') { 
        sh 'touch vaibhav.txt' 
    }
    stage('Deploy') { 
        sh 'mkdir komal'
    }
}