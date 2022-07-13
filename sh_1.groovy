job('example-1') {
    steps {
        shell('echo Hello World!')
    }
}

job('example-2') {
    steps {
        shell('echo hello')
    }
}