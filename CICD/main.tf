module "jenkins" {
  source            = "../ami-jenkins-jfrog"
  aws_region        = "us-west-2"
  aws_instance_type = "t2.medium"
  aws_key           = "jenkins-jgrog-key1"
  qa_server         = false
  jfrog_server      = true
  profile           = "default"
  jenkins_ami       = "ami-0d42f5f72bb8673de"
  jfrog_ami         = "ami-0c855d6dd26dcf269"	
  role_name         = "jenkinsAdminRoleAmi2"
  qa_uat_sg_name    = "qa-uat-security-group"
  jenkins_sg_name   = "jenkins-security-group"
  jfrog_sg_name     = "jfrog-security-group"
}

