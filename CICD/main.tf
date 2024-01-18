module "jenkins" {
  source            = "../ami-jenkins-jfrog"
  aws_region        = "us-west-2"
  aws_instance_type = "t2.medium"
  aws_key           = "jenkins-jgrog-key1"
  qa_server         = true
  jfrog_server      = true
  profile           = "default"
  jenkins_ami       = "ami-01bcc841d18872d85"
  jfrog_ami         = "ami-0fe1f3b5152381463"
  role_name         = "jenkinsAdminRoleAmi1"
  qa_uat_sg_name    = "qa-uat-security-group"
  jenkins_sg_name   = "jfrog-security-group"
  jfrog_sg_name     = "jenkins-security-group"
}

