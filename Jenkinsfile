pipeline {
    agent any

    environment {
        ARTIFACT_DIR = 'artifacts'
        BUILD_VERSION = "1.0.${BUILD_NUMBER}"
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                echo "=== STAGE: Checkout ==="
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Build version: ${BUILD_VERSION}"
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                echo "=== STAGE: Validate -- Syntax & structure checks ==="
                script {
                    def requiredFiles = [
                        'src/Deploy-Endpoint.ps1',
                        'src/Set-Baseline.ps1',
                        'tests/Test-Deploy.ps1',
                        'tests/Test-Baseline.ps1'
                    ]
                    requiredFiles.each { file ->
                        if (!fileExists(file)) {
                            error("Required file missing: ${file}")
                        }
                        echo "  + Found: ${file}"
                    }
                }
            }
        }

        stage('Build') {
            steps {
                echo "=== STAGE: Build -- Generate baseline artifact ==="
                powershell '''
                    if (-not (Test-Path ".\\artifacts")) {
                        New-Item -ItemType Directory -Path ".\\artifacts" | Out-Null
                    }

                    & pwsh -File ".\\src\\Set-Baseline.ps1" -OutputPath ".\\artifacts\\baseline-dev.json" -Environment Dev
                    & pwsh -File ".\\src\\Set-Baseline.ps1" -OutputPath ".\\artifacts\\baseline-staging.json" -Environment Staging

                    Write-Host "Build artifacts generated:"
                    Get-ChildItem ".\\artifacts" | Format-Table Name, Length, LastWriteTime
                '''
            }
        }

        stage('Test') {
            parallel {
                stage('Test: Deploy Script') {
                    steps {
                        echo "=== PARALLEL TEST: Deploy-Endpoint ==="
                        powershell '''
                            $result = & pwsh -File ".\\tests\\Test-Deploy.ps1"
                            $result | ForEach-Object { Write-Host $_ }
                            if ($LASTEXITCODE -ne 0) {
                                throw "Test-Deploy.ps1 failed with exit code $LASTEXITCODE"
                            }
                        '''
                    }
                }
                stage('Test: Baseline Script') {
                    steps {
                        echo "=== PARALLEL TEST: Set-Baseline ==="
                        powershell '''
                            $result = & pwsh -File ".\\tests\\Test-Baseline.ps1"
                            $result | ForEach-Object { Write-Host $_ }
                            if ($LASTEXITCODE -ne 0) {
                                throw "Test-Baseline.ps1 failed with exit code $LASTEXITCODE"
                            }
                        '''
                    }
                }
            }
        }

        stage('Package') {
            steps {
                echo "=== STAGE: Package -- Create versioned artifact bundle ==="
                powershell """
                    \$packageName = "ps-deployment-toolkit-${BUILD_VERSION}.zip"
                    \$packagePath = ".\\artifacts\\\$packageName"

                    \$filesToPack = Get-ChildItem -Path ".\\src", ".\\artifacts" -File -Recurse
                    Compress-Archive -Path \$filesToPack.FullName -DestinationPath \$packagePath -Force

                    Write-Host "Package created: \$packagePath"
                    Write-Host "Package size: \$((Get-Item \$packagePath).Length) bytes"
                """
            }
        }

        stage('Report') {
            steps {
                echo "=== STAGE: Report -- Build summary ==="
                powershell """
                    Write-Host "Artifacts produced:"
                    Get-ChildItem ".\\${ARTIFACT_DIR}" | Format-Table Name, Length, LastWriteTime -AutoSize
                    Write-Host ""
                    Write-Host "Build ${BUILD_VERSION} completed successfully."
                """
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "=== STAGE: Deploy -- Ansible deployment to dev ==="
                powershell """
                    Write-Host "Triggering Ansible deployment for version ${BUILD_VERSION}..."
                    Write-Host "Target: devops-ansible-deploy pipeline (dev environment)"
                    Write-Host "Run: ansible-playbook -i ansible/inventory/hosts.ini ansible/deploy.yml -e env=dev -e app_version=${BUILD_VERSION}"
                    Write-Host "Deploy stage complete -- see devops-ansible-deploy repo for full Ansible pipeline."
                """
            }
        }
    }

    post {
        success {
            echo "BUILD SUCCESS -- All stages passed. Version: ${BUILD_VERSION}"
            archiveArtifacts artifacts: 'artifacts/**/*', fingerprint: true
        }
        failure {
            echo "BUILD FAILED -- Check stage logs above for details."
        }
        always {
            echo "Pipeline complete. Exit: ${currentBuild.result}"
        }
    }
}
